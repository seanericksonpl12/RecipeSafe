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
    private let scriptTag: String = "script[type=application/ld+json]"
    
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
                var recipe = try self.soupify(html: $0)
                recipe?.url = url
                return recipe
            }
            .catch { _ in
                return Fail(error: NetworkError.invalidURL("Bad URL")).eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Web Scraping
    private func soupify(html: String) throws -> Recipe? {
        let doc: Document = try SwiftSoup.parse(html)
        let scripts = try doc.select(scriptTag).first()?.data()
        guard let jsonString = scripts?.data(using: .utf8, allowLossyConversion: false) else { return nil }
        
        let json = try JSON(data: jsonString)
        guard let dict = searchFor(keys: JSONKeys.allCases.map({$0.rawValue}),
                                   excluding: ["review"],
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
