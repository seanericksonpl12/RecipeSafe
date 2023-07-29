//
//  GPTRequest.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 7/26/23.
//

import Foundation

struct GPTResponse: Codable {
    var id: String?
    var object: String?
    var created: Int?
    var choices: [Choice]
    var usage: Usage?
    
    struct Choice: Codable {
        var index: Int?
        var message: [String: String]
        var finish_reason: String?
    }
    
    struct Usage: Codable {
        var prompt_tokens: Int?
        var completion_tokens: Int?
        var total_tokens: Int?
    }
}

struct GPTRequest: NetworkRequest {
    
    typealias Response = Recipe
    
    private let apiKey: String =  {
        if let path = Bundle.main.path(forResource: "Info", ofType: "plist"), let dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject] {
            return dict["OpenAIKey"] as? String ?? ""
        } else { return "" }
    }()
    
    var url: String {
        let base: String = "https://api.openai.com/v1"
        let path: String = "/chat/completions"
        return base + path
    }
    
    var header: [String : String] {
        [
            "Content-Type" : "application/json",
            "Authorization" : "Bearer \(apiKey)"
        ]
    }
    
    var method: HTTPMethod? { .post }
    
    var messages: [[String: String]] = [
        ["role": "system", "content": "The user will give you JSON representing a recipe, you will tell them the title, ingredients, instructions, description, thumbnail image url, cook time, and prep time of the recipe."]
    ]
    
    var body: Data? {
        let uncodedBody: [String: Any] = [
            "model" : "gpt-3.5-turbo",
            "messages" : messages
        ]
        
        return try? JSONSerialization.data(withJSONObject: uncodedBody, options: .prettyPrinted)
    }
    
    mutating func addMessage(_ message: [String:String]) {
        messages.append(message)
    }
    
    func decode(_ data: Data) throws -> Recipe {
        let decoder = JSONDecoder()
        let gptResponse = try decoder.decode(GPTResponse.self, from: data)
        print(gptResponse)
        guard let jsonString = gptResponse.choices[0].message["content"] else {
            print("json string fail.")
            throw URLError(.cannotParseResponse)
        }
        guard let data: Data = jsonString.data(using: .utf8) else {
            print("data encoding failed.")
            throw URLError(.cannotParseResponse)
        }
        return try JSONDecoder().decode(Recipe.self, from: data)
    }
}
