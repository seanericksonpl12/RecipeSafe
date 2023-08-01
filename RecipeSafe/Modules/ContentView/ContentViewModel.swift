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
    private var waitingRecipe = Recipe(title: "", ingredients: [])
    private var waitingDuplicate: RecipeItem?
    private var network: NetworkManager = NetworkManager()
    
    var gpt: GPTSocket = GPTSocket()
    
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
        
        let sharedData = PersistenceController.shared
        
        guard var newRecipe = recipe else {
            displayBadSite = true
            return
        }
        if let duplicate = sharedData.findDuplicates(newRecipe) {
            self.duplicateFound = true
            waitingRecipe = newRecipe
            waitingDuplicate = duplicate
        } else {
            DispatchQueue.main.async {
                newRecipe.dataEntity = sharedData.saveItem(recipe: newRecipe)
                self.navPath.append(newRecipe)
            }
        }
    }
    
    
    // MARK: - Core Data Functions
    func overwriteRecipe(deletingDup: Bool = false) {
        let sharedData = PersistenceController.shared
        if let dup = waitingDuplicate, deletingDup {
            sharedData.container.viewContext.delete(dup)
        }
        DispatchQueue.main.async { self.waitingRecipe.dataEntity = sharedData.saveItem(recipe: self.waitingRecipe) }
        self.navPath.append(waitingRecipe)
        self.waitingDuplicate = nil
    }
    
    func cancelOverwrite() {
        self.waitingDuplicate = nil
        self.duplicateFound = false
    }
    
    func deleteItem(offset: IndexSet,
                    list: FetchedResults<RecipeItem>,
                    context: NSManagedObjectContext) {
        offset
            .map { list[$0] }
            .forEach { context.delete($0) }
        do {
            try context.save()
        } catch {
            print("viewContext error.")
        }
    }
}

