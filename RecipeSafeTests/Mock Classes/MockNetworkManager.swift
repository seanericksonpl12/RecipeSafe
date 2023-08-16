//
//  MockNetworkManager.swift
//  RecipeSafeTests
//
//  Created by Sean Erickson on 8/3/23.
//

import Foundation
import Combine
@testable import RecipeSafe

class MockNetworkManager: NetworkManager {
    
    var returnValidInput: Bool = false
    
    override func networkRequest(url: URL) -> AnyPublisher<Recipe, Error> {
        if returnValidInput {
            let recipe = Recipe(title: "Test Title",
                                description: "Test Description",
                                ingredients: ["i 1", "i 2"],
                                instructions: ["in 1", "in 2"],
                                img: .none,
                                url: nil,
                                prepTime: "10 min",
                                cookTime: "20 min")
            return Just(recipe)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        else {
            return Fail(error: NetworkError.badResponse("Bad Response")).eraseToAnyPublisher()
        }
    }
}
