//
//  Recipe.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 7/13/23.
//

import Foundation
import SwiftyJSON

struct Recipe: Hashable {
    
    // MARK: - Core Data Init
    init?(dataItem: RecipeItem) {
        guard let id = dataItem.id else { return nil }
        guard let title = dataItem.title else { return nil }
        guard let ingredientArr = dataItem.ingredients?.allObjects as? [Ingredient] else { return nil }
        guard let instructionArr = dataItem.instructions?.array as? [Instruction] else { return nil }
        if ingredientArr.contains(where: { $0.value == nil }) { return nil }
        if instructionArr.contains(where: { $0.value == nil }) { return nil }
        
        self.id = id
        self.title = title
        self.ingredients = ingredientArr.map { $0.value! }
        self.instructions = instructionArr.map { $0.value! }
        self.description = dataItem.desc
        self.cookTime = dataItem.cookTime
        self.prepTime = dataItem.prepTime
        self.img = dataItem.imageUrl
        self.url = dataItem.url
    }
    
    // MARK: - JSON Init
    init?(json: JSON) {
        let info = json[JSONKeys.allInfo.rawValue]
        if info.isEmpty || !info.exists() { return nil }
        
        let title: String = info[0][JSONKeys.title.rawValue].stringValue
        let ingrd: [String] = info[7].filter { $0.0.contains(JSONKeys.ingredient.rawValue)}[0].1.arrayValue.map { $0.stringValue }
        let img: URL? = info[0][JSONKeys.imageUrl.rawValue].url
        let description: String = info[1][JSONKeys.description.rawValue].stringValue
        let instructions: [String] = info[7][JSONKeys.instructions.rawValue].arrayValue.map { $0[JSONKeys.instructionValue.rawValue].stringValue }
        let prep = info[7][JSONKeys.prepTime.rawValue].stringValue
        let cook = info[7][JSONKeys.cookTime.rawValue].stringValue
        let url = info[7][JSONKeys.url.rawValue].url
        
        guard let checkedUrl = url else { return nil }
        
        if title == "" || ingrd.isEmpty || instructions.isEmpty || checkedUrl.absoluteString == "" {
            return nil
        }
        
        self.title = title
        self.ingredients = ingrd
        self.img = img
        self.description = description
        self.instructions = instructions
        self.prepTime = prep
        self.cookTime = cook
        self.url = checkedUrl
    }
    
    // MARK: - Testing Init
    init(title: String, ingredients: [String], img: URL? = nil) {
        self.title = title
        self.ingredients = ingredients
        self.img = img
        self.instructions = []
    }
    
    // MARK: - Properties
    var id: UUID = UUID()
    var title: String
    var ingredients: [String]
    var img: URL?
    var url: URL?
    var description: String?
    var instructions: [String]
    var prepTime: String?
    var cookTime: String?
}

fileprivate enum JSONKeys: String {
    case allInfo = "@graph"
    case description
    case title = "headline"
    case ingredient = "recipeIngredient"
    case instructions = "recipeInstructions"
    case instructionValue = "text"
    case imageUrl = "thumbnailUrl"
    case prepTime
    case cookTime
    case url
}
