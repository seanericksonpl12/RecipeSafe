//
//  AppManager.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 8/14/23.
//

import Foundation
import SwiftUI
import Nuke
import Injector

@MainActor
class AppViewModel: ObservableObject {
    // MARK: - Dependencies
    @GlobalInjected(\.appConfig) var appConfig
    
    // MARK: - Wrapped
    @Published var tabSelection: Int = 1
    @Published var displayBadSite: Bool = false
    @Published var duplicateFound: Bool = false
    @Published var launchTutorial: Bool = false
    @Published var allRecipesViewModel: AllRecipesViewModel
    @Published var groupViewModel: GroupGridViewModel
    @Published var viewState: ViewState = .started
    
    // MARK: - Persistance
    let persistenceController = PersistenceController.shared
    
    // MARK: - Private Properties
    private var network: NetworkManager = NetworkManager()
    @Service private var dataManager: DataManager!
    private var fetchedRecipe: Recipe?
    private var waitingRecipe = Recipe()
    private var waitingDuplicate: RecipeItem?
    
    // MARK: - Init
    init(networkManager: NetworkManager = NetworkManager()) {
        self.allRecipesViewModel = AllRecipesViewModel()
        self.groupViewModel = GroupGridViewModel()
        self.network = networkManager
        self.launchTutorial = !UserDefaults.standard.hasLaunchedBefore
        self.dataManager.appUpdate()
        Nuke.ImagePipeline.shared = ImagePipeline(configuration: .withDataCache)
    }
}

// MARK: - URL Open
extension AppViewModel {
    
    func onURLOpen(url: URL) {
        self.viewState = .loading
        Task { @MainActor in
            switch await network.networkRequest(url: url) {
            case .success(let recipe):
                self.handleNewRecipe(recipe)
            case .failure(let error):
                self.handleFailure()
                print(error.localizedDescription)
            }
        }
    }
}

// MARK: - Private Handling
extension AppViewModel {
    
    // MARK: - Handle Failure
    private func handleFailure() {
        self.viewState = .failedToLoad
        self.displayBadSite = true
    }
    
    // MARK: - Handle Recipe
    private func handleNewRecipe(_ recipe: Recipe) {
        self.viewState = .successfullyLoaded
        var newRecipe = recipe
        if let duplicate = dataManager.findDuplicates(newRecipe) {
            self.duplicateFound = true
            self.waitingRecipe = newRecipe
            self.waitingDuplicate = duplicate
        } else {
            newRecipe.dataEntity = dataManager.saveItem(recipe)?.objectID
            self.openRecipe(newRecipe)
        }
    }
    
    // MARK: - Open Recipe
    private func openRecipe(_ recipe: Recipe) {
        let groups: [GroupItem] = dataManager.getItems(filter: {_ in true})
        if groups.isEmpty {
            self.tabSelection = 1
            self.allRecipesViewModel.handleNewRecipe(recipe)
        } else {
            self.tabSelection = 2
            self.groupViewModel.handleNewRecipe(recipe)
        }
    }
}

// MARK: - Public Handling
extension AppViewModel {
    
    func overwriteRecipe(deletingDup: Bool = false) {
        if let dup = waitingDuplicate, deletingDup {
            self.dataManager.deleteItem(dup)
        }
        self.waitingRecipe.dataEntity = self.dataManager.saveItem(self.waitingRecipe)?.objectID
        self.waitingDuplicate = nil
        self.openRecipe(self.waitingRecipe)
    }
    
    func cancelOverwrite() {
        self.waitingDuplicate = nil
        self.duplicateFound = false
    }
}
