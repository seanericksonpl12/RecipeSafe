import Dependencies
import Foundation

public struct AppAttestationDataService: Sendable {
  var attestApp: @Sendable ([String: Any]) async throws -> Void
  var challege: @Sendable () async throws -> Data
}

extension AppAttestationDataService: DependencyKey {
  public static let liveValue = AppAttestationDataService(
    attestApp: { body in
      _ = try await HttpClient().request(
        url: Endpoints.attest.fullUrl,
        method: .post,
        body: .json(body),
        queryItems: nil,
        headers: nil
      )
    },
    challege: {
      try await HttpClient().request(url: Endpoints.challenge.fullUrl)
    }
  )

  public static let testValue = AppAttestationDataService(
    attestApp: { _ in },
    challege: { Data() }
  )
}

extension DependencyValues {
  var appAttestationDataService: AppAttestationDataService {
    get { self[AppAttestationDataService.self] }
    set { self[AppAttestationDataService.self] = newValue }
  }
}
