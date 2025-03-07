//
//  AppAttestService.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 2/23/25.
//

import CoreData
import DeviceCheck
import CryptoKit

struct AppAttestService: Sendable, Service {
    private static let keyId = "RECIPE_SAFE_APP_ATTEST_KEY_ID"
    static var defaultValue: Self { .mock }
    
    var generateAttestation: @Sendable (Data) async throws -> String
    var generateAssertion: @Sendable (Data) async throws -> String
    
    static var mock: Self { .defaultValue }
    
    static func live(viewContext: NSManagedObjectContext, client: NetworkClient) -> Self {
        .init(
            generateAttestation: { challenge in
                guard DCAppAttestService.shared.isSupported else { throw DCError(.featureUnsupported) }
                
                var key = UserDefaults.standard.string(forKey: keyId)
                if key == nil {
                    key = try await DCAppAttestService.shared.generateKey()
                    UserDefaults.standard.set(key, forKey: keyId)
                }
                guard let key else { throw DCError(.invalidKey) }
                
                let clientDataHash = Data(SHA256.hash(data: challenge))
                
                let attestation = try await DCAppAttestService.shared.attestKey(key, clientDataHash: clientDataHash)
                
                return attestation.base64EncodedString()
            },
            generateAssertion: { challenge in
                guard let key = UserDefaults.standard.string(forKey: keyId) else { throw DCError(.invalidKey) }
                
                let clientDataHash = Data(SHA256.hash(data: challenge))
                
                let assertion = try await DCAppAttestService.shared.generateAssertion(key, clientDataHash: clientDataHash)
                
                return assertion.base64EncodedString()
            }
        )
    }
    
}
