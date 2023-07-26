//
//  RecipeViewModel.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 7/18/23.
//

import Foundation
import SwiftUI
import Combine
import CoreData


@MainActor class RecipeViewModel: ObservableObject {
    @Published var recipe: Recipe
    @Published var editingEnabled: Bool = false
    @Published var titleText: String = ""
    @Published var descriptionText: String = ""
    @Published var confirmationPopup: Bool = false
    
    init(recipe: Recipe) {
        self.recipe = recipe
        self.descriptionText = recipe.description ?? ""
        self.titleText = recipe.title
    }
    
    func saveChanges() {
        
        withAnimation {
            self.editingEnabled = false
        }
        self.recipe.dataEntity?.title = self.recipe.title
        self.recipe.dataEntity?.desc = self.descriptionText
        self.recipe.description = self.descriptionText
        
        let context = PersistenceController.shared.container.viewContext
        self.recipe.instructions.removeAll { $0 == "" }
        self.recipe.ingredients.removeAll { $0 == "" }
        
        self.recipe.dataEntity?.ingredients = []
        self.recipe.dataEntity?.instructions = []
        self.recipe.ingredients.forEach {
            let i = Ingredient(context: context)
            i.value = $0
            self.recipe.dataEntity?.addToIngredients(i)
        }
        self.recipe.instructions.forEach {
            let i = Instruction(context: context)
            i.value = $0
            self.recipe.dataEntity?.addToInstructions(i)
        }
        
        try? context.save()
        
    }
    
    func cancelEditing() {
        
        withAnimation {
            self.editingEnabled = false
        }
        self.recipe.title = self.recipe.dataEntity?.title ?? self.recipe.title
        self.recipe.description = self.recipe.dataEntity?.desc
        self.descriptionText = self.recipe.description ?? self.descriptionText
        
        guard var ingredientArr = self.recipe.dataEntity?.ingredients?.allObjects as? [Ingredient] else { return }
        guard var instructionArr = self.recipe.dataEntity?.instructions?.array as? [Instruction] else { return }
        ingredientArr = ingredientArr.filter { $0.value != nil }
        instructionArr = instructionArr.filter { $0.value != nil }
        
        self.recipe.ingredients = ingredientArr.map { $0.value! }
        self.recipe.instructions = instructionArr.map { $0.value! }
    }
    
    func deleteFromIngr(offsets: IndexSet) {
        self.recipe.ingredients.remove(atOffsets: offsets)
    }
    
    func deleteFromInst(offsets: IndexSet) {
        self.recipe.instructions.remove(atOffsets: offsets)
    }
    
    func deleteSelf(dismissal: DismissAction) {
        if let entity = recipe.dataEntity {
            let context = PersistenceController.shared.container.viewContext
            context.delete(entity)
            try? context.save()
        }
        
        dismissal.callAsFunction()
    }
}

