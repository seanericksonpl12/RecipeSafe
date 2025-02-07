//
//  VisionRecipeViewModel.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 2/7/25.
//

import SwiftUI

class VisionRecipeViewModel: EditableRecipeModel {
    
    @Service var dataManager: DataManager!
    
    @Published var recipe: Recipe
    @Published var editingEnabled: Bool = true
    @Published var descriptionText: String
    @Published var cookText: String
    @Published var prepText: String
    @Published var alertSwitch: Bool = false
    @Published var groupSwitch: Bool = false
    @Published var savingRecipe: Bool = false
    
    var screen: Screen
    var dismiss: DismissAction?
    
    var saveAction: () -> Void
    
    var deleteAction: () -> Void
    
    var cancelAction: () -> Void
    
    var groupAction: () -> Void {{}}
    
    init(recipe: Recipe, onSave: @escaping (() -> Void), onCancel: @escaping (() -> Void)) {
        self.recipe = recipe
        self.screen = .search
        self.descriptionText = recipe.description ?? ""
        self.prepText = recipe.prepTime ?? ""
        self.cookText = recipe.cookTime ?? ""
        self.saveAction = onSave
        self.cancelAction = onCancel
        self.deleteAction = onCancel
    }
    
    func deleteSelf() {
        Task { @Sendable [weak self] in
            guard let self, let dismiss = self.dismiss else { return }
            await dismiss()
        }
    }
    
    func getGroups() -> [GroupItem] { [] }
    func addToGroup(_ group: GroupItem) { }
}
