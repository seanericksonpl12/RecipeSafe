//
//  RecipeImageRequest.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 9/16/24.
//

import Foundation

struct RecipeImageRequest: NetworkRequest {
    typealias Response = WebSearch
    
    var title: String
    
    var url: String {
        var components = URLComponents()
//        components.scheme = "https"
//        components.host = "www.foreignspyware.com"
//        components.path = "/api/recipe-safe/pageSearch"
        components.scheme = "http"
        components.host = "localhost"
        components.port = 5050
        components.path = "/api/recipe-safe/getRecipeImg"
        return components.url?.absoluteString ?? ""
    }
    
    var queryItems: [String : String] {
        [
            "title": title
        ]
    }
    
    var method: HTTPMethod? { .get }
    var body: Data? { nil }
}
