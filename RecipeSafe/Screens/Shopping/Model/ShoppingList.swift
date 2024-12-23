//
//  ShoppingList.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 10/2/24.
//

import Foundation

struct ShoppingList: Codable {
    
    var recipeIDs: [String] = []
    var allItems: [ShoppingListItem] = []
    mutating func addRecipe(_ recipe: Recipe) {
        recipeIDs.append(recipe.realId)
        allItems.append(contentsOf: recipe.ingredients.map { ShoppingListItem(ingredient: $0, selected: false, recipeId: recipe.realId)})
    }
}

struct ShoppingListItem: Codable, Identifiable {
    var id: UUID = UUID()
    
    var ingredient: String
    var selected: Bool
    var recipeId: String?
}
