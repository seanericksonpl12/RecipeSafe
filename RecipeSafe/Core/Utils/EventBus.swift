import Foundation
import Dependencies
@preconcurrency import Combine

struct EventBus: Sendable {
  private static let shared = EventBus()
  
  private let subject = PassthroughSubject<Event, Never>()
  var stream: AsyncStream<Event> {
    AsyncStream { continuation in
      let cancellable = subject.sink { result in
        switch result {
        case .finished:
          continuation.finish()
        case .failure:
          assertionFailure("Event Bus Failed")
          continuation.finish()
        }
      } receiveValue: { event in
        continuation.yield(event)
      }
      continuation.onTermination = { _ in
        cancellable.cancel()
      }
    }
  }
  
  func send(_ event: Event) {
    subject.send(event)
  }

  enum Event: Sendable, Equatable {
    case recipeDatabaseUpdated
  }
}

extension EventBus: DependencyKey {
  static let liveValue = EventBus.shared
  static let testValue = EventBus()
}

extension DependencyValues {
  var eventBus: EventBus {
    get { self[EventBus.self] }
    set { self[EventBus.self] = newValue }
  }
}
