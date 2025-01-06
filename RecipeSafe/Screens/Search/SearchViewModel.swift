//
//  SearchViewModel.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 9/3/24.
//

import Foundation
import Combine

enum SearchState: Equatable {
    case waiting, loading, loaded, backgroundRunning, failed
}

struct StoredRecipeInfo: Codable {
    var title: String?
    var link: String?
}

@MainActor
class SearchViewModel: ObservableObject {
    
    @Published var text: String = ""
    @Published var state: SearchState = .waiting
    @Published var results: [Recipe] = []
    @Published var stringCompletions: [String] = []
    @Published var presentHistory: Bool = false
    @Published var filteredAutoFillValues: [String] = []
    @Published var isSearchFocused: Bool = false
    @Published var recentSearches = RecentSearchStack()
    
    var randomRecipes: [String] = []
    
    private var network: NetworkManager = NetworkManager()
    @Service private var dataManager: DataManager!
    private var searchTask: Task<(), Error>?
    private var filterTask: Task<(), Error>?
    private var autoFillValues: [String] = []
    private var didJustSubmit: Bool = false
    private var subscribers: Set<AnyCancellable> = []
    
    lazy var suggestedRecipes: [RecipeSuggestion] = { fetchRandomRecipes() }()
    
    init() {
        $text.sink { [weak self] newText in
            self?.updatedText(text: newText)
        }.store(in: &subscribers)
    }
}

// MARK: - Functions
extension SearchViewModel {

    private func start(term: String) {
        if term.trimmingCharacters(in: .whitespaces).isEmpty {
            return
        }
        self.searchTask = Task {
            await reset()
            self.isSearchFocused = false
            self.recentSearches.add(term)
            self.state = .loading
            let request = SearchRequest(search: term, index: 0)
            do {
                let stream = try await network.executeStream(request: request)
                for try await recipe in stream {
                    self.results.append(recipe)
                    self.state = .backgroundRunning
                }
                state = .loaded
            } catch {
                if results.isEmpty {
                    state = .failed
                } else {
                    state = .loaded
                }
            }
        }
    }
    
    func suggestionTapped(text: String) {
        self.text = text
        start(term: text)
    }
    
    // TODO: - Find a better way to do this..
    func checkIfSaved(recipe: Recipe) -> Recipe {
        if let item = dataManager.findDuplicates(recipe) {
            var new = recipe
            new.dataEntity = item.objectID
            return new
        } else {
            return recipe
        }
    }
    
    private func reset() async {
        self.state = .waiting
        self.results = []
    }
    
    func seeAllTapped() {
        presentHistory = true
    }
    
    func dismissHistoryView() {
        presentHistory = false
    }
    
    func clearHistory() {
        recentSearches.clear()
    }
    
    private func updatedText(text: String) {
        if text.count == 1 {
            guard let char = text.first, char.isLetter else {
                return
            }
            // read file and save only array for first char of search. New file read if new first char
            if let file = FileUtility.read(name: "recipe_titles", type: .json, model: RecipeNameFile.self),
               let charArr = file.titles[char.uppercased()] {
                self.autoFillValues = charArr
            }
        } else if text.count == 0 {
            self.autoFillValues = []
        } 
        
        self.filterTask?.cancel()
        self.filterTask = Task(priority: .background) {
            self.filteredAutoFillValues = autoFillValues.filter({ $0.lowercased().hasPrefix(text.lowercased()) })
            if self.filteredAutoFillValues.count > 8 {
                self.filteredAutoFillValues = Array(filteredAutoFillValues[0..<8])
            }
        }
    }
    
    private func fetchRandomRecipes() -> [RecipeSuggestion] {
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

extension SearchViewModel: SearchTextFieldDelegate {
    func submit() {
        start(term: self.text)
    }
    
    func refresh() {
        searchTask?.cancel()
        start(term: self.text)
    }
    
    func cancel() {
        self.isSearchFocused = false
        presentHistory = false
    }
    
    func clear() {
        self.text = ""

        presentHistory = false
        searchTask?.cancel()
        results = []
        state = .waiting
    }
}
