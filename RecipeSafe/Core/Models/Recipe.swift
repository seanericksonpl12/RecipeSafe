//
//  Recipe.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 7/13/23.
//

import Foundation

struct Recipe: Hashable {
    
    init(dataItem: RecipeItem) {
        self.id = dataItem.id ?? UUID()
        self.title = dataItem.title ?? "error"
        self.ingredients = (dataItem.ingredients?.allObjects as? [Ingredient] ?? []).map { $0.value ?? "" }
    }
    
    init(id: UUID = UUID(), title: String, ingredients: [String], img: URL? = nil) {
        self.id = id
        self.title = title
        self.ingredients = ingredients
        self.img = img
    }
    
    var id: UUID = UUID()
    var title: String
    var ingredients: [String]
    var img: URL?
}

struct RecipeData: Codable {
    
    let context: String
    let graph: [[String:String]]
    
    
    enum CodingKeys: String, CodingKey {
        case graph = "@graph"
        case context = "@context"
    }
}
