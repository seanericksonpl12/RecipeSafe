//
//  CreateRecipeViewModel.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 7/31/23.
//

import Foundation
import SwiftUI

@MainActor class CreateRecipeViewModel: EditableRecipeModel {
    
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
        self.recipe = Recipe(title: "", ingredients: [""])
        self.recipe.instructions = [""]
    }
}


// MARK: - Functions
extension CreateRecipeViewModel {
    
    func saveChanges() {
        if recipe.title == "" {
            recipe.title = "recipe.title.new".localized
        }
        
        let context = PersistenceController.shared.container.viewContext
        let newRecipe = RecipeItem(context: context)
        newRecipe.title = recipe.title
        newRecipe.id = recipe.id
        newRecipe.cookTime = recipe.cookTime
        newRecipe.prepTime = recipe.prepTime
        newRecipe.desc = descriptionText
        newRecipe.photoData = recipe.photoData
        if recipe.instructions.contains("") {
            recipe.instructions.removeAll(where: {$0 == ""})
        }
        recipe.ingredients.forEach {
            let i = Ingredient(context: context)
            i.value = $0
            newRecipe.addToIngredients(i)
        }
        recipe.instructions.forEach {
            let i = Instruction(context: context)
            i.value = $0
            newRecipe.addToInstructions(i)
        }
        
        do {
            try context.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        cancelEditing()
    }
    
    func cancelEditing() {
        dismiss?.callAsFunction()
    }
}
