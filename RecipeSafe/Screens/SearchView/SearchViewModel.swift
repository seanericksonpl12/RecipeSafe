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
    @Published var isLoading: Bool = false
    @Published var stringCompletions: [String] = []
    @Published var isSearching: Bool = false
    @Published var seeAllRecentSearches: Bool = false
    
    // TESTING
    @Published var isFocusing: Bool = false
    
    var randomRecipes: [String] = []
    var autoFillValues: [String] = []
    var recentSearches = RecentSearchStack()
    
    private var network: NetworkManager = NetworkManager()
    private var dataManager: DataManager = DataManager()
    private var searchTask: Task<(), Error>?
    private var previousResults: [Recipe] = []
    private var didJustSubmit: Bool = false
    private var shouldProcessSubmit: Bool = true
    private var subscribers: Set<AnyCancellable> = []
    
    var filteredAutoFillValues: [String] {
        autoFillValues.filter({ $0.lowercased().hasPrefix(text.lowercased()) })
    }
    
    lazy var suggestedRecipes: [RecipeSuggestion] = { fetchRandomRecipes() }()
    
    var dismissSearch: () -> Void = { print("not set..") }
    
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
            self.recentSearches.add(term)
            self.state = .loading
            self.isLoading = true
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
            self.isLoading = false
            self.previousResults = self.results
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
            new.dataEntity = item
            return new
        } else {
            return recipe
        }
    }
    
    private func reset() async {
        self.state = .waiting
        self.results = []
    }
    
    func searchSubmitted() {
        if !shouldProcessSubmit {
            shouldProcessSubmit = true
            return
        }
        didJustSubmit = true
        let temp = text
        start(term: temp)
        dismissSearch()
        // janky text reset to not lose text on submit
        text = ""
        DispatchQueue.main.asyncAfter(deadline: .now().advanced(by: DispatchTimeInterval.milliseconds(100))) {
            self.text = temp
        }
    }
    
    func seeAllTapped() {
        shouldProcessSubmit = false
        seeAllRecentSearches = true
    }
    
    func isSearching(_ isSearching: Bool) {
        if didJustSubmit {
            didJustSubmit = false
        } else {
            cancelSearch()
        }
    }
    
    private func cancelSearch() {
        seeAllRecentSearches = false
        searchTask?.cancel()
        self.state = results.isEmpty ? .waiting : .loaded
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
    }
    
    private func fetchRandomRecipes() -> [RecipeSuggestion] {
        var recipes = [RecipeSuggestion]()
        guard let file = FileUtility.read(name: "recipes_with_images", type: .json, model: RecipeSuggestionFile.self) else {
            return []
        }
        while recipes.count < 6 {
            guard let arr = file.titles.randomElement()?.value,
                  let recipe = arr.randomElement() else {
                recipes = []
                return []
            }
            recipes.append(recipe)
        }
        return recipes
    }
}
