import ComposableArchitecture
import Dependencies
import Foundation

struct LaunchReducer: Reducer {
  typealias State = LaunchState
  typealias Action = LaunchAction
  
  var body: some ReducerOf<Self> {
    Scope(state: \.contentState, action: \.content) {
      ContentReducer()
    }
    Reduce { state, action in
      switch action {
      case .fetchAppConfig:
        return .run { send in
          let config = try await appConfigManager.fetchAppConfig()
          if config.appHealth.needsAttestation {
            try await appAttestationManager.attestApp()
          }
          await send(.appSetupComplete(.loaded))
        } catch: { error, send in
          Logger.log("Failed to load app config with error: \(error.localizedDescription)")
          await send(.appSetupComplete(.error), animation: .default)
        }
      case let .appSetupComplete(loadState):
        state.loadState = loadState
        return .none
      case let .didFinishPlayingAnimation(finished):
        state.animationFinished = finished
        return .none
      default:
        return .none
      }
    }
  }
  
  private let appConfigManager = AppConfigManager()
  private let appAttestationManager = AppAttestationManager()
  
  @ObservableState
  struct LaunchState: Sendable, Equatable {
    var loadState: LoadState = .loading
    var animationFinished: Bool = false
    var contentState = ContentState()
  }
  
  @CasePathable
  enum LaunchAction: Sendable, Equatable {
    case fetchAppConfig
    case appSetupComplete(LoadState)
    case didFinishPlayingAnimation(Bool)
    
    case content(ContentAction)
  }
  
  enum LoadState: Sendable, Equatable {
    case loading
    case loaded
    case error
  }
}
