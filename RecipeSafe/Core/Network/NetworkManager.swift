//
//  NetworkManager.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 7/13/23.
//

import Foundation

class NetworkManager: NetworkProtocol, Sendable {
    
    // MARK: - Properties
    let session: URLSession
    
    // MARK: - Inits
    init(configuration: URLSessionConfiguration) {
        self.session = URLSession(configuration: configuration)
    }
    
    convenience init() {
        self.init(configuration: .default)
    }
    
    // MARK: - Make Request
    func networkRequest(url: URL) async -> Result<Recipe, Error> {
        
        guard url.scheme == "RecipeSafe" else {
            return .failure(NetworkError.invalidURL("Bad URL scheme"))
        }
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return .failure(NetworkError.invalidURL("Could not create components"))
        }
        guard components.host == "open-recipe" else {
            return .failure(NetworkError.invalidURL("Bad URL host"))
        }
        guard let embeddedUrl = components.queryItems?.first(where: { $0.name == "url" })?.value else {
            return .failure(NetworkError.invalidURL("Bad URL queries"))
        }
        let recipeComponents = URLComponents(string: "https://".appending(embeddedUrl))
        guard let urlStr = recipeComponents?.url?.absoluteString else {
            return .failure(NetworkError.invalidURL("Could not resolve url"))
        }
        
        let slicedURL = urlStr.replacing("RecipeSafe://", with: "")
        let request = RecipeRequest(url: slicedURL)
        return  await executeRequest(request: request, retries: 0)
    }
}
