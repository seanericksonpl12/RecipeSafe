//
//  NetworkTester.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 7/26/23.
//

import Foundation
import SwiftyJSON
import SwiftSoup
import Combine

// MARK: - TEST CLASS ONLY
class NetworkTester: NetworkProtocol {
    
    
    var session: URLSession
    
    init(configuration: URLSessionConfiguration) {
        self.session = URLSession(configuration: configuration)
    }
    
    convenience init() {
        self.init(configuration: .default)
    }
    
    func testNetworkProtocol(_ url: String) -> AnyPublisher<Recipe, Error>? {
        let slicedURL = url.replacing("RecipeSafe://", with: "")
        guard let components = URLComponents(string: slicedURL) else { return nil }
        if components.scheme != "https" { return nil }
        guard let url = components.url else { return nil }
        let request = URLRequest(url: url)
        
        return execute(request: request, customDecodingStrategy: { [self] in try! htmlToRecipe(data: $0) }, retries: 0)
        
    }
    
    private func htmlToRecipe(data: Data) throws -> Recipe {
        guard let html = String(data: data, encoding: .utf8) else { throw URLError(.cannotDecodeRawData) }
        let doc: Document = try SwiftSoup.parse(html)
        let scripts = try doc.select("script[type=application/ld+json]").first()?.data()
        guard let jsonString = scripts?.data(using: .utf8, allowLossyConversion: false) else { return Recipe(title: "", ingredients: []) }
       
        let json = try JSON(data: jsonString)
        let excluding = ["review", "author"]
        let keys = JSONKeys.allCases.map{ $0.rawValue }
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
        
        return Recipe(json: rtrnDict)!
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
