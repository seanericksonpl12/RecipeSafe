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
            return Fail(error: URLError(.badServerResponse)).eraseToAnyPublisher()
        }
        return Fail(error: URLError(.badServerResponse)).eraseToAnyPublisher()
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
