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
    
    private let apiKey: String = "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"
    
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
    
    var method: HTTPMethod { .post }
    
    var messages: [[String: String]] = [
        ["role": "system", "content": "You're a friendly, helpful assistant"],
        ["role": "user", "content": "Hello Mister Robot, how many pennies do you think I can eat before getting sick"]
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
    
}
