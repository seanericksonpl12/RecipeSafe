//
//  CreateRecipeViewModel.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 7/31/23.
//

import Foundation
import SwiftUI

@MainActor class CreateRecipeViewModel: EditableRecipeModel {
    
    var dataManager: DataManager = DataManager()
    
    // MARK: - Properties
    @Published var recipe: Recipe
    @Published var editingEnabled: Bool = true
    @Published var descriptionText = ""
    var alertSwitch: Bool = false
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
    
    // MARK: - Init
    init() {
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
        let _ = dataManager.saveItem(self.recipe)
        cancelEditing()
    }
    
    func cancelEditing() {
        dismiss?.callAsFunction()
    }
}
