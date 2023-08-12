//
//  CreateRecipeViewModel.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 7/31/23.
//

import Foundation
import SwiftUI

@MainActor class CreateRecipeViewModel: EditableRecipeModel {
    
    // MARK: - Published
    @Published var recipe: Recipe
    @Published var editingEnabled: Bool = true
    @Published var descriptionText = ""
    @Published var cookText = ""
    @Published var prepText = ""
    
    // MARK: - Private
    private var dataManager: DataManager
    
    // MARK: - Properties
    var alertSwitch: Bool = false
    var groupSwitch: Bool = false
    
    var dismiss: DismissAction?
    
    // MARK: - Computed
    var saveAction: () -> Void {
        { self.saveChanges() }
    }
    
    var deleteAction: () -> Void {
        {}
    }
    
    var cancelAction: () -> Void {
        { self.cancelEditing() }
    }
    
    var groupAction: () -> Void {
        {}
    }
    
    // MARK: - Init
    init(dataManager: DataManager = DataManager()) {
        self.dataManager = dataManager
        self.recipe = Recipe()
        self.recipe.instructions = [""]
        self.recipe.ingredients = [""]
    }
}


// MARK: - Functions
extension CreateRecipeViewModel {
    
    func saveChanges() {
        if recipe.title == "" {
            recipe.title = "recipe.title.new".localized
        }
        if recipe.instructions.contains("") {
            recipe.instructions.removeAll(where: {$0 == ""})
        }
        if recipe.ingredients.contains("") {
            recipe.ingredients.removeAll(where: {$0 == ""})
        }
        recipe.description = descriptionText
        recipe.prepTime = prepText
        recipe.cookTime = cookText
        let _ = dataManager.saveItem(self.recipe)
        cancelEditing()
    }
    
    func cancelEditing() {
        dismiss?.callAsFunction()
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
}
