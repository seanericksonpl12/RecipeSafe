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
        guard let url = URL(string: url) else { return Fail(error: NetworkError.invalidURL("Bad URL")).eraseToAnyPublisher() }
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .tryMap {
                guard let str = String(data: $0, encoding: .utf8) else { throw URLError(.cannotDecodeRawData) }
                return str
            }
            .tryMap { [weak self] in
                guard let self = self else { return nil }
                return try self.soupify(html: $0)
            }
            .eraseToAnyPublisher()
            
    }
    
    func soupify(html: String) throws -> Recipe? {
        let doc: Document = try SwiftSoup.parse(html)
        let scripts = try doc.select("script[type=application/ld+json]").first()?.data()
        guard let jsonString = scripts?.data(using: .utf8, allowLossyConversion: false) else { return nil }
        
        
        let json = try JSON(data: jsonString)
        
        let ingrd =  json["@graph"][7].filter { $0.0.contains("recipeIngredient")}[0].1.arrayValue.map { $0.stringValue }
        return Recipe(title: "title", ingredients: ingrd, img: nil)
        
    }
}
