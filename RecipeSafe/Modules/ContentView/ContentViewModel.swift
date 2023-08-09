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
    @Published var duplicateFound: Bool = false
    @Published var displayBadSite: Bool = false
    @Published var viewState: ViewState = .started
    @Published var searchText: String = ""
    @Published var customRecipeSheet: Bool = false
    
    // MARK: - Properties
    private var subscriptions = Set<AnyCancellable>()
    private var waitingRecipe = Recipe()
    private var waitingDuplicate: RecipeItem?
    private var network: NetworkManager
    private var dataManager: DataManager
    
    // MARK: - Optional Init
    init(dataManager: DataManager = DataManager(),
         networkManager: NetworkManager = NetworkManager()) {
        self.dataManager = dataManager
        self.network = networkManager
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
    
    // MARK: - URL Handling
    func onURLOpen(url: URL) {
        self.navPath = .init()
        guard url.scheme == "RecipeSafe" else {
            self.displayBadSite = true
            self.viewState = .failedToLoad
            return
        }
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            self.displayBadSite = true
            self.viewState = .failedToLoad
            return
        }
        guard components.host == "open-recipe" else {
            self.displayBadSite = true
            self.viewState = .failedToLoad
            return
        }
        guard let embeddedUrl = components.queryItems?.first(where: { $0.name == "url" })?.value else {
            self.displayBadSite = true
            self.viewState = .failedToLoad
            return
        }
        let recipeComponents = URLComponents(string: "https://".appending(embeddedUrl))
        guard let urlStr = recipeComponents?.url?.absoluteString else {
            self.displayBadSite = true
            self.viewState = .failedToLoad
            return
        }
        self.viewState = .loading
        
        network.networkRequest(url: urlStr).sink { [weak self] status in
            guard let self = self else { return }
            switch status {
            case .finished:
                break
            case .failure(let error):
                self.displayBadSite = true
                self.viewState = .failedToLoad
                print(error.localizedDescription)
            }
        } receiveValue: { [weak self] recipe in
            guard let self = self else { return }
            self.viewState = .successfullyLoaded
            self.handleNewRecipe(recipe)
        }
        .store(in: &subscriptions)
    }
    
    // MARK: - Recipe Handling
    private func handleNewRecipe(_ recipe: Recipe) {
        var newRecipe = recipe
        if let duplicate = dataManager.findDuplicates(newRecipe) {
            self.duplicateFound = true
            waitingRecipe = newRecipe
            waitingDuplicate = duplicate
        } else {
            DispatchQueue.main.async {
                newRecipe.dataEntity = self.dataManager.saveItem(newRecipe)
                self.navPath = NavigationPath()
                self.navPath.append(newRecipe)
            }
        }
    }
    
    
    // MARK: - Core Data Functions
    func overwriteRecipe(deletingDup: Bool = false) {
        if let dup = waitingDuplicate, deletingDup {
            dataManager.deleteItem(dup)
        }
        DispatchQueue.main.async { self.waitingRecipe.dataEntity = self.dataManager.saveItem(self.waitingRecipe) }
        self.navPath.append(waitingRecipe)
        self.waitingDuplicate = nil
    }
    
    func cancelOverwrite() {
        self.waitingDuplicate = nil
        self.duplicateFound = false
    }
    
    func deleteItem(offset: IndexSet, list: FetchedResults<RecipeItem>) {
        dataManager.deleteItem(offset: offset, list: list)
    }
}

