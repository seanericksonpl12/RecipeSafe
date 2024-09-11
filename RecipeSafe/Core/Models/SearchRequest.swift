//
//  SearchRequest.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 9/3/24.
//

import Foundation

struct SearchRequest: NetworkRequest {
    typealias Response = WebSearch
    
    var search: String
    var index: Int
    
    var url: String  {
        let queries = queryItems.map { URLQueryItem(name: $0.key, value: $0.value)}
        var components = URLComponents()
        components.scheme = "https"
        components.host = "www.foreignspyware.com"
        components.path = "/api/recipe-safe/pageSearch"
        return components.url?.absoluteString ?? ""
    }
    
    var queryItems: [String : String] {
        [
            "search": search,
            "index": String(index)
        ]
    }
    var method: HTTPMethod? { .get }
    var body: Data? { nil }
    
    func decode(_ data: Data) throws -> WebSearch {
        print(String(data: data, encoding: .utf8))
        do {
            return try JSONDecoder().decode(WebSearch.self, from: data)
        } catch {
            let str = String(data: data, encoding: .utf8)
            print("Decoding Error, failed decoding this: \(str)")
            throw error
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
