//
//  RecipeRequest.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 7/27/23.
//

import Foundation

struct RecipeRequest: NetworkRequest {
    
    typealias Response = Recipe
    
    var url: String
    var method: HTTPMethod? { nil }
    var body: Data? { nil }
    
    func decode(_ data: Data) throws -> Recipe {
        let parser = RecipeJSONParser(data: data)
        var recipe: Recipe = try parser.parse()
        recipe.url = URL(string: self.url)
        return recipe
    }
}
