//
//  RecipeViewModel.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 7/18/23.
//

import Foundation
import SwiftUI
import CoreData

class RecipeViewModel: EditableRecipeModel {
    
    // MARK: - Wrapped
    @Published var recipe: Recipe
    @Published var editingEnabled: Bool = false
    @Published var descriptionText: String = ""
    @Published var cookText: String = ""
    @Published var prepText: String = ""
    @Published var alertSwitch: Bool = false
    @Published var groupSwitch: Bool = false
    
    // MARK: - Private
    private var dataManager: DataManager
    
    // MARK: - Properties
    var dismiss: DismissAction?
    
    // MARK: - Computed
    var saveAction: () -> Void {
        { self.saveChanges() }
    }
    
    var deleteAction: () -> Void {
        { self.toggleAlert() }
    }
    
    var cancelAction: () -> Void {
        { self.cancelEditing() }
    }
    
    var groupAction: () -> Void {
        { self.groupSwitch = true }
    }
    
    var screen: Screen
    
    // MARK: - Init
    init(recipe: Recipe, screen: Screen, dataManager: DataManager = DataManager()) {
        self.recipe = recipe
        self.screen = screen
        self.descriptionText = recipe.description ?? ""
        self.prepText = recipe.prepTime ?? ""
        self.cookText = recipe.cookTime ?? ""
        self.dataManager = dataManager
    }
}

// MARK: - Functions
extension RecipeViewModel {
    
    func saveChanges() {
        withAnimation {
            self.editingEnabled = false
        }
        self.recipe.description = self.descriptionText
        self.recipe.cookTime = self.cookText
        self.recipe.prepTime = self.prepText
        Task { @MainActor in
            self.recipe.instructions.removeAll { $0 == "" }
            self.recipe.ingredients.removeAll { $0 == "" }
            self.dataManager.updateDataEntity(recipe: self.recipe)
        }
    }
    
    func deleteSelf() {
        dataManager.deleteDataEntity(recipe: self.recipe)
        self.recipe.dataEntity = nil
        dismiss?.callAsFunction()
    }
    
    func getGroups() -> [GroupItem] {
        dataManager.getItems(filter: { _ in true })
    }
    
    func addToGroup(_ group: GroupItem) {
        dataManager.addToGroup(recipe: self.recipe, group)
    }
    
    func saveRecipe(recipe: Recipe) -> Recipe {
        var newRecipe = recipe
        newRecipe.dataEntity = dataManager.saveItem(recipe)
        return newRecipe
    }
    
    func updateRecipe() {
        print("updating")
        if screen == .search {
            if let item = dataManager.findDuplicates(recipe) {
                var new = recipe
                new.dataEntity = item
                self.recipe = new
            } else {
                self.recipe.dataEntity = nil
            }
        }
    }
}
