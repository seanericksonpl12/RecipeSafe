//
//  SearchRequest.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 9/3/24.
//

import Foundation

struct SearchRequest: NetworkRequest {
    typealias Response = Recipe
    
    // TODO: - Switch for testing!
    private var backendFormatted: Bool { true }
    
    var search: String
    var index: Int
    
    
    var url: String  {
        var components = URLComponents()
//        components.scheme = "https"
//        components.host = "www.foreignspyware.com"
//        components.path = "/api/recipe-safe/pageSearch"
        components.scheme = "http"
        components.host = "localhost"
        components.port = 5050
        components.path = "/api/recipe-safe/pageStream"
        return components.url?.absoluteString ?? ""
    }
    
    var queryItems: [String : String] {
        [
            "search": search,
            "index": String(index),
            "formatted": String(backendFormatted)
        ]
    }
    var method: HTTPMethod? { .get }
    var body: Data? { nil }
    
    func decode(_ data: Data) throws -> Recipe {
        if self.backendFormatted {
            return try JSONDecoder().decode(Recipe.self, from: data)
        } else {
            let parser = RecipeJSONParser(data: data)
            let recipe: Recipe = try parser.parseFromJSON()
            return recipe
        }
    }
}



struct WebSearch: Codable {
    var queries: Queries?
    var items: [QueryItem]?
}

struct Queries: Codable {
    var nextPage: [Page]?
}

struct Page: Codable {
    var startIndex: Int?
}

struct QueryItem: Codable {
    var link: String?
}
