//
//  NetworkManager.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 7/13/23.
//

import Foundation
import CoreData

struct NetworkService: Sendable, Service {

    let buildRecipe: @Sendable (URL) async throws -> Recipe
    let fetchAppConfig: @Sendable () async -> Void
}

extension NetworkService {
    
    static var defaultValue: Self {
        .init(
            buildRecipe: { _ in
                throw URLError(.cancelled)
            },
            fetchAppConfig: {}
        )
    }
    
    static func live(viewContext: NSManagedObjectContext, client: NetworkClient) -> Self {
        .init(
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
                print("fetching config")
                do {
                    let url = AppEnvironment.baseUrl.appending(Endpoints.appConfig.rawValue)
                    let model: AppConfigModel = try await client.request(url: url)
                    await AppConfig.shared.load(model: model)
                    print("success!")
                } catch {
                    
                    await AppConfig.shared.loadFailed()
                    print("failed with error: \(error)")
                }
            }
        )
    }
    
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
            fetchAppConfig: {
                await AppConfig.shared.load(model: AppConfigModel(featureFlags: FeatureFlags(searchEnabled: false)))
            }
        )
    }
}
