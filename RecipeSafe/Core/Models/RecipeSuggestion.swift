//
//  RecipeSuggestion.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 9/16/24.
//

import Foundation

struct RecipeNameFile: Codable {
    var titles: Dictionary<String, [String]>
}

struct RecipeSuggestionFile: Codable {
    var titles: Dictionary<String, Array<RecipeSuggestion>>
}

struct RecipeSuggestion: Codable, Hashable {
    var title: String
    var link: String
}
