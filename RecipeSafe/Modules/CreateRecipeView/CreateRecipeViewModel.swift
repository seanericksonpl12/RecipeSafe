//
//  CreateRecipeViewModel.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 7/31/23.
//

import Foundation
import SwiftUI


@MainActor class CreateRecipeViewModel: ObservableObject {
    
    @Published var recipe: Recipe
    @Published var editing: Bool = true
    @Published var descriptionText = ""
    @Published var addTitleAlert: Bool = false
    
    init() {
        self.recipe = Recipe(title: "", ingredients: [""])
        self.recipe.instructions = [""]
    }
}


// MARK: - Functions
extension CreateRecipeViewModel {
    
    func saveChanges(_ dismiss: DismissAction) {
        if recipe.title == "" {
            addTitleAlert = true
            return
        }
        
        let context = PersistenceController.shared.container.viewContext
        let newRecipe = RecipeItem(context: context)
        newRecipe.title = recipe.title
        newRecipe.id = recipe.id
        newRecipe.cookTime = recipe.cookTime
        newRecipe.prepTime = recipe.prepTime
        newRecipe.desc = descriptionText
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
        
        dismiss.callAsFunction()
    }
    
    func cancel(_ dismiss: DismissAction) {
        dismiss.callAsFunction()
    }
    
    func deleteFromIngr(offsets: IndexSet) {
        self.recipe.ingredients.remove(atOffsets: offsets)
    }
    
    func deleteFromInst(offsets: IndexSet) {
        self.recipe.instructions.remove(at: offsets.first!)
    }
}
