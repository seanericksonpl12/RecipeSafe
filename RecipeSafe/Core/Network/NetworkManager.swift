//
//  NetworkManager.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 7/13/23.
//

import Foundation
import Combine

final class NetworkManager: NetworkProtocol {
    
    var session: URLSession
    
    init(configuration: URLSessionConfiguration) {
        self.session = URLSession(configuration: configuration)
    }
    
    convenience init() {
        self.init(configuration: .default)
    }
    
    func networkRequest(url: String) -> AnyPublisher<Recipe, Error> {
        let slicedURL = url.replacing("RecipeSafe://", with: "")
        let request = RecipeRequest(url: slicedURL)
        return executeRequest(request: request, retries: 0)
    }
}
