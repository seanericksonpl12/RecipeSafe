//
//  RecipeRequest.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 7/27/23.
//

import Foundation
import SwiftSoup
import SwiftyJSON

struct RecipeRequest: NetworkRequest {
    
    
    typealias Response = Recipe
    
    var url: String
    var method: HTTPMethod? { nil }
    var body: Data? { nil }
    private let scriptTag: String = "script[type=application/ld+json]"
    
    func decode(_ data: Data) throws -> Recipe {
        guard let str = String(data: data, encoding: .utf8) else { throw URLError(.cannotDecodeRawData) }
        guard var recipe = try self.soupify(html: str) else {
            throw NetworkError.failedToDecodeJSON("Could not decode JSON data")
        }
        recipe.url = URL(string: self.url)
        return recipe
    }
    
    private func soupify(html: String) throws -> Recipe? {
        let doc: Document = try SwiftSoup.parse(html)
        let scripts = try doc.select(scriptTag).first()?.data()
        guard let jsonString = scripts?.data(using: .utf8, allowLossyConversion: false) else { return nil }
        
        let json = try JSON(data: jsonString)
        
        let dict = searchFor(keys: JSONKeys.allCases.map({$0.rawValue}),
                                   excluding: ["review", "author"],
                                   json: json)
        
        return Recipe(json: dict)
    }
    
    // MARK: - JSON Search
    private func searchFor(keys: [String],
                           excluding: [String] = [],
                           json: JSON) -> [String: JSON] {
        
        var rtrnDict = [String: JSON]()
        var queue: [JSON] = []
        print(json)
        queue.append(json)
        
        while(!queue.isEmpty && rtrnDict.count < keys.count) {
            
            let cur = queue.remove(at: 0)
            let arr = cur.arrayValue
            let dict = cur.dictionaryValue
            
            if !arr.isEmpty {
                queue.append(contentsOf: arr)
            }
            else if !dict.isEmpty {
                keys.forEach {
                    if let val = dict[$0] { rtrnDict[$0] = val }
                }
                
                dict.forEach {
                    if !excluding.contains($0.key) {
                        queue.append($0.value)
                    }
                }
            }
        }
        return rtrnDict
    }
    
    private enum JSONKeys: String, CaseIterable {
        case recipeIngredient
        case recipeInstructions
        case headline
        case thumbnailUrl
        case description
        case cookTime
        case prepTime
        case name
    }
}
