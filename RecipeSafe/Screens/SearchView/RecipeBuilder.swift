//
//  ExampleViewModel.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 9/4/24.
//

import Foundation

final actor RecipeBuilder {
    
    unowned let viewModel: SearchViewModel
    
    private var network: NetworkManager = NetworkManager()
    private let pageLimit: Int = 30
    private var pageIndex: Int = 0
    private var isFirst: Bool = true
    
    init(viewModel: SearchViewModel) {
        self.viewModel = viewModel
    }
}

// MARK: - Main Actor Isolated
extension RecipeBuilder {
    nonisolated
    func updateState(_ state: SearchState) {
        Task { @MainActor in
            viewModel.state = state == .failed && !viewModel.results.isEmpty ? .loaded : state
        }
    }
    
    nonisolated
    func updateResults(recipe: Recipe) {
        Task { @MainActor in
            if viewModel.results.isEmpty {
                viewModel.state = .loaded
            }
            viewModel.results.append(recipe)
        }
    }
}

// MARK: - Self Isolated
extension RecipeBuilder {
    
    func fetchUrls(searchTerm: String) async throws -> [String]? {
        if pageIndex == -1 || pageIndex >= pageLimit {
            return nil
        }
        let request = SearchRequest(search: searchTerm, index: pageIndex)
        let result = await network.executeRequest(request: request, retries: 0)
        switch result {
        case .success(let page):
            pageIndex = page.queries?.nextPage?.first?.startIndex ?? -1
            if isFirst {
                isFirst = false
                updateState(.backgroundRunning)
            }
            return page.items?.compactMap { $0.link }
        case .failure(let error):
            throw error
        }
    }
    
    func reset() {
        self.isFirst = true
        self.pageIndex = 0
    }
}


// MARK: - Nonisolated
extension RecipeBuilder {
    
    nonisolated
    func startSearch(for term: String) async {
        do {
            while let urls = try await fetchUrls(searchTerm: term) {
                await fetchRecipes(for: urls)
            }
            updateState(.loaded)
        } catch {
            let error = error
            print(error)
            updateState(.failed)
        }
    }
    
    nonisolated
    func fetchRecipes(for urls: [String]) async {
        await withTaskGroup(of: Recipe?.self) { group in
            for url in urls { group.addTask { await self.createRecipe(from: url) } }
            for await recipe in group.compactMap({$0}) {
                updateResults(recipe: recipe)
            }
        }
    }
    
    nonisolated
    func createRecipe(from url: String) async -> Recipe? {
        let request = RecipeRequest(url: url)
        let response = await network.executeRequest(request: request, retries: 0)
        switch response {
        case .success(let recipe):
            return recipe
        case .failure(let error):
            print("task failed with error \(error)")
            return nil
        }
    }
}

typealias WebSocketStream = AsyncThrowingStream<URLSessionWebSocketTask.Message, Error>

extension URLSessionWebSocketTask {
    var stream: WebSocketStream {
        return WebSocketStream { continuation in
            Task {
                var isAlive = true

                while isAlive && closeCode == .invalid {
                    do {
                        let value = try await receive()
                        continuation.yield(value)
                    } catch {
                        continuation.finish(throwing: error)
                        isAlive = false
                    }
                }
            }
        }
    }
}
