//
//  ContentViewModel.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 7/13/23.
//

import Foundation
import SwiftUI
import CoreData
import Combine

extension ContentView {
    @MainActor class ContentViewModel: ObservableObject {
        @Published var recipe: Recipe? = Recipe(title: "", ingredients: [])
        var website: String = "https://therecipecritic.com/easy-shrimp-tacos/"
        
        var subscriptions = Set<AnyCancellable>()
        
        private lazy var recipePublisher: AnyPublisher<Recipe?, Never> = {
               return NetworkManager.main.networkRequest(url: website)
                    .receive(on: DispatchQueue.main)
                    .catch { error in
                        return Just(Recipe(title: "", ingredients: []))
                    }
                    .eraseToAnyPublisher()
        }()
        
        init() {
            recipePublisher.assign(to: &$recipe)
        }
    }
}
