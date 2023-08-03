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
    private let network: NetworkManager = NetworkManager()
    private let dataManager: DataManager = DataManager()
    
    // MARK: - Computed Properties
    var searchList: (FetchedResults<RecipeItem>) -> [RecipeItem] {
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
    func onURLOpen(url: String) {
        self.viewState = .loading
        self.navPath = .init()
        network.networkRequest(url: url).sink { [weak self] status in
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
            self.handleNewRecipe(recipe)
        }
        .store(in: &subscriptions)
    }
    
    // MARK: - Recipe Handling
    private func handleNewRecipe(_ recipe: Recipe?) {
        self.viewState = .successfullyLoaded
        
        guard var newRecipe = recipe else {
            displayBadSite = true
            return
        }
        if let duplicate = dataManager.findDuplicates(newRecipe) {
            self.duplicateFound = true
            waitingRecipe = newRecipe
            waitingDuplicate = duplicate
        } else {
            DispatchQueue.main.async {
                newRecipe.dataEntity = self.dataManager.saveItem(newRecipe)
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

