////
////  EditableRecipeModel.swift
////  RecipeSafe
////
////  Created by Sean Erickson on 8/1/23.
////
//
//import Foundation
//import SwiftUI
//
//enum Screen {
//    case allRecipes, groups, search
//}
//
//protocol EditableRecipeModel: ObservableObject {
//    
//    var dataManager: DataManager { get }
//    
//    // MARK: - Properties
//    var recipe: Recipe { get set }
//    var screen: Screen { get }
//    var editingEnabled: Bool { get set }
//    var descriptionText: String { get set }
//    var cookText: String { get set }
//    var prepText: String { get set }
//    var alertSwitch: Bool { get set }
//    var groupSwitch: Bool { get set }
//    var dismiss: DismissAction? { get set }
//    
//    // MARK: - Actions
//    var saveAction: () -> Void { get }
//    var deleteAction: () -> Void { get }
//    var cancelAction: () -> Void { get }
//    var groupAction: () -> Void { get }
//    
//    
//    // MARK: - Functions
//    func saveChanges() async
//    func cancelEditing()
//    func toggleAlert()
//    func deleteFromIngr(offsets: IndexSet)
//    func deleteFromInst(offsets: IndexSet)
//    func deleteSelf()
//    func getGroups() -> [GroupItem]
//    func addToGroup(_ group: GroupItem)
//    func setup(dismiss: DismissAction)
//    func saveRecipe(recipe: Recipe) -> Recipe
//    func updateRecipe()
//}
//
//// MARK: - Defaults
//extension EditableRecipeModel {
//    
//    // MARK: - Default Functions
//    func setup(dismiss: DismissAction) {
//        print("dismiss")
//        self.dismiss = dismiss
//    }
//    
//    func cancelEditing() {
//        Task { @MainActor in
//            withAnimation {
//                self.editingEnabled = false
//            }
//        }
//        let entity: RecipeItem? = dataManager.object(with: self.recipe.dataEntity)
//        self.recipe.title = entity?.title ?? self.recipe.title
//        self.recipe.description = entity?.desc ?? ""
//        if let data = entity?.photoData {
//            self.recipe.img = .selected(data)
//        }
//        self.descriptionText = self.recipe.description.isEmpty ? self.descriptionText : self.recipe.description
//        self.prepText = self.recipe.prepTime.isEmpty ? self.prepText : self.recipe.prepTime
//        self.cookText = self.recipe.cookTime.isEmpty ? self.cookText : self.recipe.cookTime
//        
//        guard var ingredientArr = entity?.ingredients?.array as? [Ingredient] else { return }
//        guard var instructionArr = entity?.instructions?.array as? [Instruction] else { return }
//        ingredientArr = ingredientArr.filter { $0.value != nil }
//        instructionArr = instructionArr.filter { $0.value != nil }
//        
//        self.recipe.ingredients = ingredientArr.map { $0.value! }
//        self.recipe.instructions = instructionArr.map { $0.value! }
//
//    }
//    
//    func deleteFromIngr(offsets: IndexSet) {
//        self.recipe.ingredients.remove(atOffsets: offsets)
//    }
//    
//    func deleteFromInst(offsets: IndexSet) {
//        self.recipe.instructions.remove(atOffsets: offsets)
//    }
//    
//    func toggleAlert() {
//        self.alertSwitch = true
//    }
//    
//    func saveRecipe(recipe: Recipe) -> Recipe {
//        recipe
//    }
//    
//    func updateRecipe() {
//        print("updating from wrong spot")
//    }
//}
