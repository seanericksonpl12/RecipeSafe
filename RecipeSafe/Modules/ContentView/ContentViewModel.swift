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

@MainActor class ContentViewModel: ObservableObject {
    
    // MARK: - Published
    @Published var navPath: NavigationPath = .init()
    @Published var searchText: String = ""
    @Published var customRecipeSheet: Bool = false
    
    // MARK: - Private Properties
    private var dataManager: DataManager
    
    // MARK: - Init
    init(dataManager: DataManager = DataManager()) {
        self.dataManager = dataManager
    }
    
    // MARK: - Computed Properties
    var searchList: (any RandomAccessCollection<RecipeItem>) -> [RecipeItem] {
        { [self] list in
            if searchText.isEmpty {
                return Array(list)
            } else {
                return list.filter({ $0.title?.lowercased().contains(searchText.lowercased()) ?? false })
            }
        }
    }
}


// MARK: - Functions
extension ContentViewModel {
    
    func handleNewRecipe(_ recipe: Recipe) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.navPath.append(recipe)
        }
    }
    
    func deleteItem(offset: IndexSet, list: FetchedResults<RecipeItem>) {
        dataManager.deleteItem(offset: offset, list: list)
    }
}

