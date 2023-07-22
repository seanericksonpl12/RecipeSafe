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
        let scripts = try doc.select(scriptTag).first()?.data()
        guard let jsonString = scripts?.data(using: .utf8, allowLossyConversion: false) else { return nil }
        let json = try JSON(data: jsonString)
        return Recipe(json: json)
    }
    
    // MARK: - TESTING ONLY
    private func printJSON(json: JSON) {
        let info = json["@graph"]
        print("count: \(info.count)")
        print("0: \(info[0])")
        print("1: \(info[1])")
        print("2: \(info[2])")
        print("3: \(info[3])")
        print("4: \(info[4])")
        print("5: \(info[5])")
        print("6: \(info[6])")
        print("7: \(info[7])")
    }
}
