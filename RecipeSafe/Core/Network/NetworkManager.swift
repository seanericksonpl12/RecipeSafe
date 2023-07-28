//
//  NetworkManager.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 7/13/23.
//

import Foundation
import Combine
import SwiftSoup
import SwiftyJSON

final class NetworkManager: NetworkProtocol {
    
    var session: URLSession
    private let scriptTag: String = "script[type=application/ld+json]"
    
    init(configuration: URLSessionConfiguration) {
        self.session = URLSession(configuration: configuration)
    }
    
    convenience init() {
        self.init(configuration: .default)
    }
    
    func networkRequest(url: String) -> AnyPublisher<Recipe, Error> {
        let slicedURL = url.replacing("RecipeSafe://", with: "")
        
        let request = RecipeRequest(url: slicedURL)
        
        return executeRequest(request: request, retries: 0)
    }
    
    func gptRequest(url: String) -> AnyPublisher<Recipe, Error> {
        let slicedURL = url.replacing("RecipeSafe://", with: "")
        guard let url = URL(string: slicedURL) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        guard let html = try? String(contentsOf: url, encoding: .utf8) else {
            return Fail(error: URLError(.badServerResponse)).eraseToAnyPublisher()
        }
        
        do {
            let doc: Document = try SwiftSoup.parse(html)
            let scripts = try doc.select("script[type=application/ld+json]").first()?.data()
            guard let jsonData = scripts?.data(using: .utf8, allowLossyConversion: false) else {
                return Fail(error: URLError(.badServerResponse)).eraseToAnyPublisher()
            }
            
            let json = try JSON(data: jsonData).rawString(.utf8, options: [])
            if let jsonString = json {
                
                var newRequest = GPTRequest()
                newRequest.messages = [
                    ["role": "system", "content": "The user will give you JSON representing a recipe, you will tell them the title, ingredients, instructions, description, thumbnail, cook time, and prep time of the recipe in json format using keys \"title\", \"ingredients\", \"instructions\", \"description\", \"thumbnail\", \"cook_time\", \"prep_time\""],
                    ["role": "user", "content": "Here is the json: \(jsonString)"]
                ]
                return executeRequest(request: newRequest, retries: 0)
            }
        } catch {
            print("failed")
        }
        return Fail(error: URLError(.badServerResponse)).eraseToAnyPublisher()
    }
    
    // MARK: - Web Scraping
    private func soupify(html: String) throws -> Recipe? {
        let doc: Document = try SwiftSoup.parse(html)
        let scripts = try doc.select(scriptTag).first()?.data()
        guard let jsonString = scripts?.data(using: .utf8, allowLossyConversion: false) else { return nil }
        
        let json = try JSON(data: jsonString)
        guard let dict = searchFor(keys: JSONKeys.allCases.map({$0.rawValue}),
                                   excluding: ["review", "author"],
                                   json: json)
        else { return nil }
        
        return Recipe(json: dict)
    }
    
    // MARK: - JSON Search
    private func searchFor(keys: [String],
                           excluding: [String] = [],
                           json: JSON) -> [String: JSON]? {
        
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
