import Dependencies
import Foundation

struct AppConfigManager {
  func fetchAppConfig() async throws -> AppConfig {
    let config = try await appConfigDataService.fetchAppConfig()
    await appConfigCache.set(config)
    return config
  }

  @Dependency(\.appConfigDataService)
  private var appConfigDataService

  @Dependency(\.appConfigCache)
  private var appConfigCache
}
