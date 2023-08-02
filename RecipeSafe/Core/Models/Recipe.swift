//
//  Recipe.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 7/13/23.
//

import Foundation
import SwiftyJSON

struct Recipe: Hashable, Decodable, Identifiable {
    
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
    var photoData: Data?
    var dataEntity: RecipeItem?
    
    // MARK: - Core Data Init
    init?(dataItem: RecipeItem) {
        guard let id = dataItem.id else { return nil }
        guard let title = dataItem.title else { return nil }
        guard let ingredientArr = dataItem.ingredients?.array as? [Ingredient] else { return nil }
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
        self.photoData = dataItem.photoData
        self.dataEntity = dataItem
    }
    
    // MARK: - Testing Init
    init() {
        self.title = ""
        self.ingredients = []
        self.instructions = []
    }
    
    // MARK: - General Init
    init(title: String,
         description: String?,
         ingredients: [String],
         instructions: [String],
         img: URL?,
         url: URL?,
         prepTime: String?,
         cookTime: String?) {
        
        self.title = title
        self.description = description
        self.ingredients = ingredients
        self.instructions = instructions
        self.img = img
        self.url = url
        self.prepTime = prepTime
        self.cookTime = cookTime
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decode(String.self, forKey: .title)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        self.ingredients = try container.decode(Array<String>.self, forKey: .ingredients)
        self.instructions = try container.decode(Array<String>.self, forKey: .instructions)
        self.img = URL(string: try container.decodeIfPresent(String.self, forKey: .thumbnail) ?? "")
        self.cookTime = try container.decodeIfPresent(String.self, forKey: .cook_time)
        self.prepTime = try container.decodeIfPresent(String.self, forKey: .prep_time)
    }
    
    enum CodingKeys: String, CodingKey {
        case title, description, ingredients, instructions
        case thumbnail = "thumbnail"
        case cook_time = "cook_time"
        case prep_time = "prep_time"
    }
}
