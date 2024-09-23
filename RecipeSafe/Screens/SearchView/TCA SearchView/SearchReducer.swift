//
//  SearchReducer.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 9/21/24.
//

import ComposableArchitecture
import Foundation


@Reducer
struct SearchReducer {
    
    private let network = NetworkManager()
    
    enum NetworkState {
        case waiting, loading, backgroundLoading, success, failure
    }
    
    enum ScreenState {
        case suggestions, recentResults, history, recipes, failure, autocomplete
    }
    
    enum CancelID {
        case search
    }
    
    @ObservableState
    struct State {
        var screenState: ScreenState = .suggestions
        var textFieldState: SearchTextFieldReducer.State
        var networkState: NetworkState = .waiting
        var results: [Recipe] = []
        var recentSearches = RecentSearchStack()
        var seeAllRecentSearches = false
        var suggestedRecipes:  [RecipeSuggestion] = []
        var tileSize: CGSize = .zero
        var filteredAutocomplete: [String] = []
        var fullAutocomplete: [String] = []
        
        // internal
        var isSearchFocused: Bool = false
    }
    
    enum Action {
        case viewDidAppear
        case searchTextField(SearchTextFieldReducer.Action)
        case searchSubmitTapped
        case searchResponse(Error?)
        case searchRecipeResponse(Recipe)
        case searchBarTapped
        case seeAllSearchesTapped
        case recentSearchTapped
        case clearHistoryTapped
        case clearSearchTapped
        case cancelTapped
        case sizeChanged(CGSize)
        case saveFilteredAutocomplete([String])
        case saveFullAutocomplete([String])
        
        // Suggestion View
        case searchItemTapped(String)
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: \.textFieldState, action: \.searchTextField) {
            SearchTextFieldReducer()
        }
        
        Reduce { state, action in
            switch action {
            case .viewDidAppear:
                if state.suggestedRecipes.isEmpty {
                    state.suggestedRecipes = fetchSuggestions()
                }
                
            case .sizeChanged(let size):
                state.tileSize = size
                
            case .searchSubmitTapped:
                state.networkState = .loading
                return .run {
                    await runSearch($0)
                }.cancellable(id: CancelID.search)
                
            case .searchResponse(let error):
                if error != nil && state.results.isEmpty {
                    state.networkState = .failure
                } else {
                    state.networkState = .success
                }
                
            case .searchRecipeResponse(let recipe):
                state.results.append(recipe)
                
            case .searchBarTapped:
                return .none
                
            case .seeAllSearchesTapped:
                return .none
                
            case .recentSearchTapped:
                return .none
                
            case .clearHistoryTapped:
                return .none
                
            case .clearSearchTapped:
                return .none
                
            case .cancelTapped:
                return .none
                
            case .searchTextField(.submitted):
                return .send(.searchSubmitTapped)
                
            case .searchTextField(.textChanged(let text)):
                return .none
                
            case .searchTextField:
                return .none
                
            case .searchItemTapped(let title):
                return .send(.searchTextField(.textChanged(title)))
                    .concatenate(with: .send(.cancelTapped))
                    .concatenate(with: .send(.searchSubmitTapped))
                
            case .saveFilteredAutocomplete(let strings):
                state.filteredAutocomplete = strings
                
            case .saveFullAutocomplete(let strings):
                state.fullAutocomplete = strings
                
            }
            return .none
        }
        
        // MARK: - Reduce Screen State
        Reduce { state, action in
            if state.textFieldState.isFocused {
                if state.textFieldState.text.isEmpty && !state.seeAllRecentSearches && !state.recentSearches.recentArray.isEmpty {
                    state.screenState = .recentResults
                } else if state.seeAllRecentSearches && !state.recentSearches.fullArray.isEmpty {
                    state.screenState = .history
                } else {
                    state.screenState = .autocomplete
                }
            } else {
                if !state.results.isEmpty {
                    state.screenState = .recipes
                }
                state.screenState = .suggestions
            }
            return .none
        }._printChanges()
    }
}

// MARK: - Effects
extension SearchReducer {
    
    func runSearch(_ send: Send<Action>) async {
        let request = SearchRequest(search: "beef tacos", index: 0)
        do {
            let stream = try await network.executeStream(request: request)
            for try await recipe in stream {
                await send(.searchRecipeResponse(recipe))
            }
            await send(.searchResponse(nil))
        } catch {
            await send(.searchResponse(error))
        }
    }
    
    func fetchSuggestions() -> [RecipeSuggestion] {
        var recipes = [RecipeSuggestion]()
        var killswitch = 0
        guard let file = FileUtility.read(name: "recipes_with_images", type: .json, model: RecipeSuggestionFile.self) else {
            return []
        }
        while recipes.count < 6 {
            guard killswitch < 10,
                  let arr = file.titles.randomElement()?.value,
                  let recipe = arr.randomElement() else {
                recipes = []
                return []
            }
            if !recipes.contains(recipe) {
                recipes.append(recipe)
            }
            killswitch += 1
        }
        return recipes
    }
}
