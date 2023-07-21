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

final class NetworkManager {
    
    static let main: NetworkManager = NetworkManager()
    
    func networkRequest(url: String) -> AnyPublisher<Recipe?, Error> {
        let slicedURL = url.replacing("RecipeSafe://", with: "")
        guard let components = URLComponents(string: slicedURL) else { return Fail(error: NetworkError.invalidURL("Bad URL")).eraseToAnyPublisher() }
        if components.scheme != "https" { return Fail(error: NetworkError.invalidURL("Bad URL")).eraseToAnyPublisher() }
        guard let url = components.url else { return Fail(error: NetworkError.invalidURL("Bad URL")).eraseToAnyPublisher() }
        let session = URLSession.shared
        session.configuration.tlsMinimumSupportedProtocolVersion = .TLSv13
        return session.dataTaskPublisher(for: url)
            .map(\.data)
            .tryMap {
                guard let str = String(data: $0, encoding: .utf8) else { throw URLError(.cannotDecodeRawData) }
                return str
            }
            .tryMap { [weak self] in
                guard let self = self else { return nil }
                return try self.soupify(html: $0)
            }
            .catch { _ in
                return Fail(error: NetworkError.invalidURL("Bad URL")).eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
        
    }
    
    func soupify(html: String) throws -> Recipe? {
        let doc: Document = try SwiftSoup.parse(html)
        let scripts = try doc.select(JSONKeys.scriptTag.rawValue).first()?.data()
        guard let jsonString = scripts?.data(using: .utf8, allowLossyConversion: false) else { return nil }
        
        
        let json = try JSON(data: jsonString)
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
        
        var recipe = Recipe(title: title, ingredients: ingrd, img: img)
        recipe.description = description
        recipe.instructions = instructions
        recipe.prepTime = prep
        recipe.cookTime = cook
        recipe.url = url
        
        
//        print("instructions: \(instructions)")
//
//
//        print("count: \(info.count)")
//        print("0: \(info[0])")
//        print("1: \(info[1])")
//        print("2: \(info[2])")
//        print("3: \(info[3])")
//        print("4: \(info[4])")
//        print("5: \(info[5])")
//        print("6: \(info[6])")
//        print("7: \(info[7])")
        
        return recipe
        
    }
    
    private enum JSONKeys: String {
        case scriptTag = "script[type=application/ld+json]"
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
}
