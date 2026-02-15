import Dependencies
import Foundation

public struct AppConfigDataService: Sendable {
  var fetchAppConfig: @Sendable () async throws -> AppConfig
}

extension AppConfigDataService: DependencyKey {
  public static let liveValue = AppConfigDataService(
    fetchAppConfig: { try await HttpClient().request(url: Endpoints.appConfig.fullUrl) }
  )

  public static let testValue = AppConfigDataService(
    fetchAppConfig: { AppConfig.mock }
  )
}

extension DependencyValues {
  var appConfigDataService: AppConfigDataService {
    get { self[AppConfigDataService.self] }
    set { self[AppConfigDataService.self] = newValue }
  }
}
