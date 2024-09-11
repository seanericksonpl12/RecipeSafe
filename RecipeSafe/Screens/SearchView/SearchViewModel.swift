//
//  SearchViewModel.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 9/3/24.
//

import Foundation

enum SearchState: Equatable {
    case waiting, loading, loaded, backgroundRunning, failed
}

@MainActor
class SearchViewModel: ObservableObject {
    @Published var text: String = ""
    @Published var state: SearchState = .waiting
    @Published var results: [Recipe] = []
    @Published var isLoading: Bool = false
    
    private var network: NetworkManager = NetworkManager()
    private var searchTask: Task<(), Error>?
    private var previousResults: [Recipe] = []
    private var _recipeBuilder: RecipeBuilder?
    private var recipeBuilder: RecipeBuilder {
        if _recipeBuilder != nil {
            return _recipeBuilder!
        } else {
            let actor = RecipeBuilder(viewModel: self)
            _recipeBuilder = actor
            return actor
        }
    }

    func start() {
        self.searchTask = Task {
            await reset()
            self.state = .loading
            self.isLoading = true
            await self.recipeBuilder.startSearch(for: text)
            self.isLoading = false
            self.previousResults = self.results
        }
    }
    
    private func reset() async {
        self.state = .waiting
        self.results = []
        await self.recipeBuilder.reset()
    }
}

extension SearchViewModel: SearchTextFieldDelegate {
    func submit() {
        self.start()
    }
    
    func refresh() {
        self.start()
    }
    
    func cancel() {
        self.searchTask?.cancel()
        self.results = previousResults
    }
}
