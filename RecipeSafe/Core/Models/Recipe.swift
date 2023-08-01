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
    
    // MARK: - JSON Init
    init?(json: [String: JSON]) {
        
        guard let title: String =
                json[JSONKeys.title.rawValue]?
            .stringValue
            .htmlFormatted() ??
                json[JSONKeys.name.rawValue]?
            .stringValue
            .htmlFormatted()
                
        else { print("no title"); return nil }
        
        guard let ingrd: [String] =
                json[JSONKeys.ingredient.rawValue]?
            .arrayValue
            .map({
                $0.stringValue.htmlFormatted()
            })
                
        else { print("no ingredients"); return nil }
        
        guard var instructions: [String] =
                json[JSONKeys.instructions.rawValue]?
            .arrayValue
            .map({
                $0[JSONKeys.instructionValue.rawValue].stringValue.htmlFormatted()
            })
                
        else { print("no instructions"); return nil }
        
        if instructions.contains("") {
            instructions =
            json[JSONKeys.instructions.rawValue]?
                .arrayValue
                .map({
                    $0.stringValue.htmlFormatted()
                }) ?? []
        }
        
        if instructions.contains("") {
            instructions = []
            print("new instructions")
            json[JSONKeys.instructions.rawValue]?
                .arrayValue
                .map({
                    $0[JSONKeys.instructionValueWrapper.rawValue].arrayValue
                })
                .forEach {
                    $0.forEach {
                        let instruction = $0[JSONKeys.instructionValue.rawValue].stringValue.htmlFormatted()
                        instructions.append(instruction)
                    }
                }
        }
        
        if instructions.contains("") {
            return nil
        }
        
        let img: URL? = json[JSONKeys.imageUrl.rawValue]?
            .url
        
        let description = json[JSONKeys.description.rawValue]?
            .stringValue
            .htmlFormatted()
        
        let prep = json[JSONKeys.prepTime.rawValue]?
            .stringValue
            .htmlFormatted()
            .replacingOccurrences(of: "PT", with: "")
        
        let cook = json[JSONKeys.cookTime.rawValue]?
            .stringValue
            .htmlFormatted()
            .replacingOccurrences(of: "PT", with: "")
        
        if title == "" || ingrd.isEmpty || instructions.isEmpty  {
            print("empty variable")
            return nil
        }
        
        self.title = title
        self.ingredients = ingrd
        self.img = img
        self.description = description
        self.instructions = instructions
        self.prepTime = prep
        self.cookTime = cook
    }
    
    // MARK: - Testing Init
    init(title: String, ingredients: [String], img: URL? = nil) {
        self.title = title
        self.ingredients = ingredients
        self.img = img
        self.instructions = []
    }
    
    enum CodingKeys: String, CodingKey {
        case title, description, ingredients, instructions
        case thumbnail = "thumbnail"
        case cook_time = "cook_time"
        case prep_time = "prep_time"
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
}

fileprivate enum JSONKeys: String {
    case description
    case title = "headline"
    case ingredient = "recipeIngredient"
    case instructions = "recipeInstructions"
    case instructionValue = "text"
    case instructionValueWrapper = "itemListElement"
    case imageUrl = "thumbnailUrl"
    case prepTime
    case cookTime
    case name
}

struct DecodableRecipe: Codable {
    let title: String
    let description: String?
    let ingredients: [String]
    let instructions: [String]
    let imageUrl: URL?
    let prepTime: String
    let cookTime: String
    
    enum CodingKeys: String, CodingKey {
        case title, description, ingredients, instructions
        case imageUrl = "thumbnail"
        case cookTime = "cook_time"
        case prepTime = "prep_time"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decode(String.self, forKey: .title)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        self.ingredients = try container.decode(Array<String>.self, forKey: .ingredients)
        self.instructions = try container.decode(Array<String>.self, forKey: .instructions)
        self.imageUrl = try container.decode(URL.self, forKey: .imageUrl)
        self.cookTime = try container.decode(String.self, forKey: .cookTime)
        self.prepTime = try container.decode(String.self, forKey: .prepTime)
    }
    
}
