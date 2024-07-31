//
//  GroupViewModel.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 8/10/23.
//

import Foundation
import SwiftUI

class GroupGridViewModel: ObservableObject {
    
    // MARK: - Wrapped
    @Published var navPath: NavigationPath = .init()
    @Published var editingEnabled: Bool = false
    @Published var addGroupSwitch: Bool = false
    @Published var deleteGroupSwitch: Bool = false
    @Published var newRecipeSwitch: Bool = false
    @Published var newGroupText: String = ""
    @Published var selectedRecipes: [RecipeItem] = []
    @Published var newGroupColor: Int16?
    
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
            Task { @MainActor in
                self.navPath.append(group)
                self.navPath.append(recipe)
            }
        }
        
        self.cancelAction = {
            self.newRecipeSwitch = false
            guard let recipe = self.newRecipe else { return }
            Task {  @MainActor in
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
        self.newGroupColor = dataManager.getNewColor()
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
        dataManager.addGroup(title: newGroupText, recipes: selectedRecipes, color: self.newGroupColor)
        addGroupSwitch = false
    }
    
    func cancelNewGroup() {
        addGroupSwitch = false
        newGroupText = ""
        newGroupColor = nil
        selectedRecipes = []
    }
}

// MARK: - New Recipe Handling
extension GroupGridViewModel {
    
    func handleNewRecipe(_ recipe: Recipe) {
        self.navPath = .init()
        self.newRecipe = recipe
        Task { @MainActor in
            self.newRecipeSwitch = true
        }
    }
}
