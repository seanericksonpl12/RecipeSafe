//
//  JSONParser.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 8/2/23.
//

import Foundation
import SwiftSoup
import SwiftyJSON

extension Recipe {
    
    private static let scriptTag: String = "script[type=application/ld+json]"
    
    static func fromHtml(_ data: Data) throws -> Recipe {
        guard let html = String(data: data, encoding: .utf8) else {
            throw URLError(.cannotDecodeRawData)
        }
        
        let doc: Document = try SwiftSoup.parse(html)
        let scripts = try doc.select(scriptTag).first()?.data()
        guard let jsonString = scripts?.data(using: .utf8, allowLossyConversion: false) else {
            throw NetworkError.failedToDecodeJSON("Missing script data")
        }
        let json = try JSON(data: jsonString)
        let dict = searchFor(keys: JSONKeys.allCases.map({$0.rawValue}),
                                   excluding: ["review", "author"],
                                   json: json)
        
        return try createRecipe(json: dict)
    }
    
    static func parseFromJSON(data: Data) throws -> Recipe {
        let json = try JSON(data: data, options: .fragmentsAllowed)
        let dict = searchFor(keys: JSONKeys.allCases.map({$0.rawValue}),
                                   excluding: ["review", "author"],
                                   json: json)
        
        return try createRecipe(json: dict)
    }
}

// MARK: - Private Helpers
extension Recipe {
    
    // MARK: - JSON Search
    private static func searchFor(keys: [String],
                           excluding: [String] = [],
                           json: JSON) -> [String: JSON] {
        
        var rtrnDict = [String: JSON]()
        var queue: [JSON] = []
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
                    if let val = dict[$0], rtrnDict[$0] == nil { rtrnDict[$0] = val }
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
    
    // MARK: - JSON Cleaning
    private static func createRecipe(json: [String:JSON]) throws -> Recipe {
        guard let title: String =
                json[RecipeKeys.title.rawValue]?
            .stringValue
            .htmlFormatted() ??
                json[RecipeKeys.name.rawValue]?
            .stringValue
            .htmlFormatted()
                
        else { throw NetworkError.recipeMissingItem("No Title") }
        print("FOUND YIELD: \(json["recipeYield"])")
        guard let ingrd: [String] =
                json[RecipeKeys.ingredient.rawValue]?
            .arrayValue
            .map({
                $0.stringValue.recipeFormatted()
            })
                
        else { throw NetworkError.recipeMissingItem("No Ingredients") }
        
        guard var instructions: [String] =
                json[RecipeKeys.instructions.rawValue]?
            .arrayValue
            .map({
                $0[RecipeKeys.instructionValue.rawValue].stringValue.recipeFormatted()
            })
                
        else { throw NetworkError.recipeMissingItem("No Instructions") }
        instructions = instructions.filter({$0 != ""})
        if instructions.isEmpty {
            instructions =
            json[RecipeKeys.instructions.rawValue]?
                .arrayValue
                .map({
                    $0.stringValue.recipeFormatted()
                }) ?? []
            instructions = instructions.filter({$0 != ""})
        }
        
        if instructions.isEmpty {
            instructions = []
            json[RecipeKeys.instructions.rawValue]?
                .arrayValue
                .map({
                    $0[RecipeKeys.instructionValueWrapper.rawValue].arrayValue
                })
                .forEach {
                    $0.forEach {
                        let instruction = $0[RecipeKeys.instructionValue.rawValue].stringValue.recipeFormatted()
                        instructions.append(instruction)
                    }
                }
        }
        
        if instructions.contains("") {
            throw NetworkError.recipeMissingItem("No Instructions")
        }
        
        var img: ImageData = .none
        
        if let imgUrl = json[RecipeKeys.imageUrl.rawValue]?.url {
            var components = URLComponents(url: imgUrl, resolvingAgainstBaseURL: false)
            components?.query = ""
            img = .downloaded(components?.url ?? imgUrl)
        }
        
        let description = json[RecipeKeys.description.rawValue]?
            .stringValue
            .htmlFormatted()
        
        let prep = json[RecipeKeys.prepTime.rawValue]?
            .stringValue
            .htmlFormatted()
            .timeFormatted()
        
        let cook = json[RecipeKeys.cookTime.rawValue]?
            .stringValue
            .htmlFormatted()
            .timeFormatted()
        
        if title == "" || ingrd.isEmpty || instructions.isEmpty  {
            throw NetworkError.recipeMissingItem("One or more properties are empty")
        }
      return .init(
        id: UUID(),
        title: title,
        description: description ?? "",
        ingredients: ingrd.map { .init(id: UUID(), value: $0) },
        instructions: instructions.map { .init(id: UUID(), value: $0) },
      )
//        return Self(
//            title: title,
//            description: description,
//            ingredients: ingrd,
//            instructions: instructions,
//            img: img,
//            url: nil,
//            prepTime: prep,
//            cookTime: cook
//        )
    }
    
    // MARK: - Keys
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
    
    private enum RecipeKeys: String {
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
}
