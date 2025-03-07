//
//  NetworkManager.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 7/13/23.
//

import Foundation
import CoreData
import DeviceCheck
import CryptoKit

struct NetworkService: Sendable, Service {

    private static let keyId = "RECIPE_SAFE_APP_ATTEST_KEY_ID"
    let buildRecipe: @Sendable (URL) async throws -> Recipe
    let fetchAppConfig: @Sendable () async throws -> AppConfig
    let attestApp: @Sendable () async throws -> Void
    let recipeImage: @Sendable (Data) async throws -> Recipe
}

extension NetworkService {
    
    static var defaultValue: Self {
        .init(
            buildRecipe: { _ in
                throw URLError(.cancelled)
            },
            fetchAppConfig: { throw URLError(.cancelled) },
            attestApp: {},
            recipeImage: { _ in throw URLError(.cancelled)}
        )
    }
    
    static var live: Self {
        let client = HttpClient(session: URLSession.shared)
        return .init(
            buildRecipe: { url in
                
                guard url.scheme == "RecipeSafe" else {
                    throw NetworkError.invalidURL("Bad URL scheme")
                }
                guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
                    throw NetworkError.invalidURL("Could not create components")
                }
                guard components.host == "open-recipe" else {
                    throw NetworkError.invalidURL("Bad URL host")
                }
                guard let embeddedUrl = components.queryItems?.first(where: { $0.name == "url" })?.value else {
                    throw NetworkError.invalidURL("Bad URL queries")
                }
                let recipeComponents = URLComponents(string: "https://".appending(embeddedUrl))
                guard let urlStr = recipeComponents?.url?.absoluteString else {
                    throw NetworkError.invalidURL("Could not resolve url")
                }
                
                let slicedURL = urlStr.replacing("RecipeSafe://", with: "")
                
                let data: Data = try await client.request(url: slicedURL)
                
                var recipe = try Recipe.fromHtml(data)
                recipe.url = URL(string: slicedURL)
                
                return recipe
            },
            fetchAppConfig: {
                let key = UserDefaults.standard.string(forKey: keyId)
                return try await client.request(
                    url: Endpoints.appConfig.fullUrl,
                    method: .post,
                    body: .raw(AppConfig.Parameters(attestationKey: key)),
                    queryItems: nil,
                    headers: nil
                )
            },
            attestApp: {
                guard DCAppAttestService.shared.isSupported else { throw DCError(.featureUnsupported) }
                var key = UserDefaults.standard.string(forKey: keyId)
                if key == nil {
                    key = try await DCAppAttestService.shared.generateKey()
                    UserDefaults.standard.set(key, forKey: keyId)
                }
                guard let key else { throw DCError(.invalidKey) }
                let challenge = try await client.request(url: Endpoints.challenge.fullUrl)
                let clientDataHash = Data(SHA256.hash(data: challenge))
                let attestation = try await DCAppAttestService.shared.attestKey(key, clientDataHash: clientDataHash)
                let attestationString = attestation.base64EncodedString()
                let body: [String: Any] = ["attestation": attestationString, "challenge": String(data: challenge, encoding: .utf8) ?? Data(), "keyId": key]
                let _ = try await client.request(
                    url: Endpoints.attest.fullUrl,
                    method: .post,
                    body: .json(body),
                    queryItems: nil,
                    headers: nil
                )
            },
            recipeImage: { imageData in
                guard let key = UserDefaults.standard.string(forKey: keyId) else { throw DCError(.invalidKey) }
                let challenge = try await client.request(url: Endpoints.challenge.fullUrl)
                let clientDataHash = Data(SHA256.hash(data: challenge))
                let assertion = try await DCAppAttestService.shared.generateAssertion(key, clientDataHash: clientDataHash)
                let headers = ["keyid": key, "assertion": assertion.base64EncodedString()]
                let temp: RecipeFromImage = try await client.request(url: Endpoints.imageAnalysis.fullUrl, method: .post, body: .json(["image": imageData.base64EncodedString(), "challenge": String(data: challenge, encoding: .utf8) ?? ""]), queryItems: nil, headers: headers)
                return Recipe(title: temp.title, description: temp.description, ingredients: temp.ingredients, instructions: temp.instructions, img: .selected(imageData), url: nil, prepTime: nil, cookTime: nil)
            }
        )
    }
}

struct ImageRequest: Encodable {
    let image: String
}

extension NetworkService {
    
    static var mock: Self {
        .init(
            buildRecipe: { url in
                try await Task.sleep(nanoseconds: 1_000_000_000)
                return Recipe(
                    title: "Mock Recipe",
                    description: "Mock Description",
                    ingredients: [
                        "Ingredient 1",
                        "Ingredient 2",
                        "Ingredient 3"
                    ],
                    instructions: [
                        "Step 1",
                        "Step 2",
                        "Step 3"
                    ],
                    img: .none,
                    url: nil,
                    prepTime: "10 min",
                    cookTime: "30 min"
                )
            },
            fetchAppConfig: { .defaultValue },
            attestApp: {},
            recipeImage: { _ in
                try await Task.sleep(nanoseconds: 2_000_000_000)
                return Recipe(
                    title: "Image Created Recipe",
                    description: "A recipe created from taking a picture",
                    ingredients: [
                        "mock 1",
                        "mock 2"
                    ],
                    instructions: [
                        "step 1",
                        "step 2"
                    ],
                    img: .none,
                    url: nil,
                    prepTime: "20 min",
                    cookTime: "30 min"
                )
            }
        )
    }
}
