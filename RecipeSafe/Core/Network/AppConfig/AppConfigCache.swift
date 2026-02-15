import Dependencies
import Foundation

public struct AppConfigCache: Sendable {
  var get: @Sendable () -> AppConfig?
  var set: @Sendable (AppConfig) async -> Void
}

extension AppConfigCache: DependencyKey {
  nonisolated(unsafe) private static var appConfig: AppConfig?
  
  public static let liveValue = AppConfigCache(
    get: { appConfig },
    set: { config in
      await MainActor.run {
        appConfig = config
      }
    }
  )

  public static let testValue = AppConfigCache(
    get: { AppConfig.mock },
    set: { _ in }
  )
}

extension DependencyValues {
  var appConfigCache: AppConfigCache {
    get { self[AppConfigCache.self] }
    set { self[AppConfigCache.self] = newValue }
  }
}
