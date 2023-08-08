//
//  EditableRecipeModel.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 8/1/23.
//

import Foundation
import SwiftUI
import Combine

@MainActor protocol EditableRecipeModel: ObservableObject {
    
    // MARK: - Properties
    var recipe: Recipe { get set }
    var editingEnabled: Bool { get set }
    var descriptionText: String { get set }
    var cookText: String { get set }
    var prepText: String { get set }
    var alertSwitch: Bool { get set }
    var dismiss: DismissAction? { get set }
    
    // MARK: - Actions
    var saveAction: () -> Void { get }
    var deleteAction: () -> Void { get }
    var cancelAction: () -> Void { get }
    
    
    // MARK: - Functions
    func saveChanges()
    func cancelEditing()
    func toggleAlert()
    func deleteFromIngr(offsets: IndexSet)
    func deleteFromInst(offsets: IndexSet)
    func deleteSelf()
    func setup(dismiss: DismissAction)
}

// MARK: - Defaults
extension EditableRecipeModel {
    
    // MARK: - Default Functions
    func setup(dismiss: DismissAction) {
        self.dismiss = dismiss
    }
    
    func cancelEditing() {
        withAnimation {
            self.editingEnabled = false
        }
        
        self.recipe.title = self.recipe.dataEntity?.title ?? self.recipe.title
        self.recipe.description = self.recipe.dataEntity?.desc
        if let data = self.recipe.dataEntity?.photoData {
            self.recipe.img = .selected(data)
        }
        self.descriptionText = self.recipe.description ?? self.descriptionText
        self.prepText = self.recipe.prepTime ?? self.prepText
        self.cookText = self.recipe.cookTime ?? self.cookText
        DispatchQueue.main.async {
            guard var ingredientArr = self.recipe.dataEntity?.ingredients?.array as? [Ingredient] else { return }
            guard var instructionArr = self.recipe.dataEntity?.instructions?.array as? [Instruction] else { return }
            ingredientArr = ingredientArr.filter { $0.value != nil }
            instructionArr = instructionArr.filter { $0.value != nil }
            
            self.recipe.ingredients = ingredientArr.map { $0.value! }
            self.recipe.instructions = instructionArr.map { $0.value! }
        }
    }
    
    func deleteFromIngr(offsets: IndexSet) {
        self.recipe.ingredients.remove(atOffsets: offsets)
    }
    
    func deleteFromInst(offsets: IndexSet) {
        self.recipe.instructions.remove(atOffsets: offsets)
    }
    
    func toggleAlert() {
        self.alertSwitch = true
    }
    
}
