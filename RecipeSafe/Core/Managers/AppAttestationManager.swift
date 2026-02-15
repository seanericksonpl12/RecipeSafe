import Foundation
import Dependencies
import DeviceCheck
import CryptoKit

public struct AppAttestationManager: Sendable {

  private let keyId = "RECIPE_SAFE_APP_ATTEST_KEY_ID"
  
  func attestApp() async throws {
    guard DCAppAttestService.shared.isSupported else { throw DCError(.featureUnsupported) }
    var key = UserDefaults.standard.string(forKey: keyId)
    if key == nil {
        key = try await DCAppAttestService.shared.generateKey()
        UserDefaults.standard.set(key, forKey: keyId)
    }
    guard let key else { throw DCError(.invalidKey) }
    let challenge = try await appAttestationDataService.challege()
    let clientDataHash = Data(SHA256.hash(data: challenge))
    let attestation = try await DCAppAttestService.shared.attestKey(key, clientDataHash: clientDataHash)
    let attestationString = attestation.base64EncodedString()
    let body: [String: Any] = ["attestation": attestationString, "challenge": String(data: challenge, encoding: .utf8) ?? Data(), "keyId": key]
    try await appAttestationDataService.attestApp(body)
  }

  @Dependency(\.appAttestationDataService)
  private var appAttestationDataService
}
