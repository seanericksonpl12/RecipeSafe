//
//  GroupViewModel.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 8/10/23.
//

import Foundation
import SwiftUI
import Combine

@MainActor class GroupGridViewModel: ObservableObject {
    
    // MARK: - Wrappers
    @Published var navPath: NavigationPath = .init()
    @Published var editingEnabled: Bool = false
    @Published var addGroupSwitch: Bool = false
    @Published var deleteGroupSwitch: Bool = false
    @Published var newRecipeSwitch: Bool = false
    @Published var newGroupText: String = ""
    @Published var selectedRecipes: [RecipeItem] = []
    
    // MARK: - Private Properties
    private var onDeckToDelete: GroupItem?
    private var dataManager: DataManager
    
    // MARK: - Stored Properties
    var selectionAction: (GroupItem) -> Void = { _ in }
    var cancelAction: () -> Void = {}
    var newRecipe: Recipe?
    
    // MARK: - Init
    init(dataManager: DataManager = DataManager()) {
        self.dataManager = dataManager
        self.setupActions()
    }
}

// MARK: - Setup
extension GroupGridViewModel {
    
    func setupActions() {
        self.selectionAction = { group in
            self.newRecipeSwitch = false
            guard let recipe = self.newRecipe else { return }
            
            self.dataManager.addToGroup(recipe: recipe, group)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.navPath.append(group)
            }
        }
        
        self.cancelAction = {
            self.newRecipeSwitch = false
            guard let recipe = self.newRecipe else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.navPath.append(recipe)
            }
        }
    }
}

// MARK: - View Functions
extension GroupGridViewModel {
    
    func toggleEdit() {
        withAnimation {
            self.editingEnabled.toggle()
        }
    }
    
    func addGroup() {
        self.newGroupText = ""
        self.selectedRecipes = []
        withAnimation {
            addGroupSwitch = true
        }
    }
    
    func toggleDeleteGroup(_ group: GroupItem) {
        self.deleteGroupSwitch = true
        self.onDeckToDelete = group
    }
    
    func deleteGroup(_ group: GroupItem) {
        dataManager.deleteItem(group)
    }
    
    func deleteOnDeck() {
        if let item = self.onDeckToDelete {
            self.deleteGroup(item)
        }
    }
    
    func getRecipes() -> [RecipeItem] {
        return dataManager.getItems(filter: { $0.group == nil })
    }
    
    func saveNewGroup() {
        dataManager.addGroup(title: newGroupText, recipes: selectedRecipes)
        addGroupSwitch = false
    }
    
    func cancelNewGroup() {
        addGroupSwitch = false
        newGroupText = ""
        selectedRecipes = []
    }
}

// MARK: - New Recipe Handling
extension GroupGridViewModel {
    
    func handleNewRecipe(_ recipe: Recipe) {
        self.navPath = .init()
        self.newRecipeSwitch = true
        self.newRecipe = recipe
    }
}
