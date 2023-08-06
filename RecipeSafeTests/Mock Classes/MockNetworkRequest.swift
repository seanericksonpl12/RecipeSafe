//
//  MockNetworkRequest.swift
//  RecipeSafeTests
//
//  Created by Sean Erickson on 8/4/23.
//

import Foundation
@testable import RecipeSafe

struct MockNetworkRequest: NetworkRequest {
    
    typealias Response = Data
    
    var url: String
    
    var method: RecipeSafe.HTTPMethod? { nil }
    
    var body: Data? { nil }
    
    func decode(_ data: Data) throws -> Data {
        return data
    }
}
