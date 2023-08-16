//
//  NetworkManager.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 7/13/23.
//

import Foundation
import Combine

class NetworkManager: NetworkProtocol {
    
    // MARK: - Properties
    var session: URLSession
    
    // MARK: - Inits
    init(configuration: URLSessionConfiguration) {
        self.session = URLSession(configuration: configuration)
    }
    
    convenience init() {
        self.init(configuration: .default)
    }
    
    // MARK: - Make Request
    func networkRequest(url: URL) -> AnyPublisher<Recipe, Error> {
        
        guard url.scheme == "RecipeSafe" else {
            return Fail(error: NetworkError.invalidURL("Bad URL scheme")).eraseToAnyPublisher()
        }
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return Fail(error: NetworkError.invalidURL("Could not create components")).eraseToAnyPublisher()
        }
        guard components.host == "open-recipe" else {
            return Fail(error: NetworkError.invalidURL("Bad URL host")).eraseToAnyPublisher()
        }
        guard let embeddedUrl = components.queryItems?.first(where: { $0.name == "url" })?.value else {
            return Fail(error: NetworkError.invalidURL("Bad URL queries")).eraseToAnyPublisher()
        }
        let recipeComponents = URLComponents(string: "https://".appending(embeddedUrl))
        guard let urlStr = recipeComponents?.url?.absoluteString else {
            return Fail(error: NetworkError.invalidURL("Could not resolve url")).eraseToAnyPublisher()
        }
        
        let slicedURL = urlStr.replacing("RecipeSafe://", with: "")
        let request = RecipeRequest(url: slicedURL)
        return executeRequest(request: request, retries: 0)
    }
}
