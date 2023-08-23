//
//  AppManager.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 8/14/23.
//

import Foundation
import Combine
import SwiftUI

@MainActor class AppViewModel: ObservableObject {
    
    // MARK: - Wrapped
    @Published var tabSelection: Int = 1
    @Published var displayBadSite: Bool = false
    @Published var duplicateFound: Bool = false
    @Published var launchTutorial: Bool = false
    @Published var contentViewModel: ContentViewModel = ContentViewModel()
    @Published var groupViewModel: GroupGridViewModel = GroupGridViewModel()
    @Published var viewState: ViewState = .started
    
    // MARK: - Persistance
    let persistenceController = PersistenceController.shared
    
    // MARK: - Private Properties
    private var network: NetworkManager = NetworkManager()
    private var dataManager: DataManager = DataManager()
    private var subscriptions = Set<AnyCancellable>()
    private var fetchedRecipe: Recipe?
    private var waitingRecipe = Recipe()
    private var waitingDuplicate: RecipeItem?
    
    // MARK: - Init
    init(networkManager: NetworkManager = NetworkManager(),
         dataManager: DataManager = DataManager()) {
        self.network = networkManager
        self.dataManager = dataManager
        self.launchTutorial = !UserDefaults.standard.hasLaunchedBefore
        self.dataManager.appUpdate()
    }
    
}

// MARK: - URL Open
extension AppViewModel {
    
    func onURLOpen(url: URL) {
        self.viewState = .loading
        network.networkRequest(url: url).sink { [weak self] status in
            guard let self = self else { return }
            switch status {
            case .finished:
                break
            case .failure(let error):
                self.handleFailure()
                print(error.localizedDescription)
            }
        } receiveValue: { [weak self] recipe in
            guard let self = self else { return }
            self.handleNewRecipe(recipe)
        }
        .store(in: &subscriptions)
    }
}

// MARK: - Private Handling
extension AppViewModel {
    
    // MARK: - Handle Failure
    private func handleFailure() {
        DispatchQueue.main.async {
            self.viewState = .failedToLoad
            self.displayBadSite = true
        }
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
            newRecipe.dataEntity = dataManager.saveItem(recipe)
            self.openRecipe(newRecipe)
        }
    }
    
    // MARK: - Open Recipe
    private func openRecipe(_ recipe: Recipe) {
        let groups: [GroupItem] = dataManager.getItems(filter: {_ in true})
        if groups.isEmpty {
            self.tabSelection = 1
            self.contentViewModel.handleNewRecipe(recipe)
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
        DispatchQueue.main.async {
            self.waitingRecipe.dataEntity = self.dataManager.saveItem(self.waitingRecipe)
            self.waitingDuplicate = nil
            self.openRecipe(self.waitingRecipe)
        }
    }
    
    func cancelOverwrite() {
        self.waitingDuplicate = nil
        self.duplicateFound = false
    }
}
