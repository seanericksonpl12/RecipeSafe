//
//  RecipeView.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 7/17/23.
//

import SwiftUI
import CoreData

struct RecipeView: View {
    
    enum Screen {
        case allRecipes, groups, search
    }
    
    // MARK: - Environment
    @Environment(\.dismiss) private var dismissView
    @Environment(\.services.recipeData) private var dataService
    
    @ObservedObject var recipeStore: RecipeStore
    
    @State var editingEnabled: Bool
    @State var descriptionText: String = ""
    @State var cookText: String = ""
    @State var prepText: String = ""
    @State var alertSwitch: Bool = false
    @State var groupSwitch: Bool = false
    
    let screen: Screen
    let createNew: Bool
    
    init(recipe: Recipe, screen: Screen, createNew: Bool = false) {
        self.recipeStore = RecipeStore(recipe: recipe)
        self.screen = screen
        self.editingEnabled = createNew
        self.createNew = createNew
        if createNew {
            if self.recipeStore.recipe.ingredients.isEmpty { self.recipeStore.recipe.ingredients = [""] }
            if self.recipeStore.recipe.instructions.isEmpty { self.recipeStore.recipe.instructions = [""] }
        }
    }
    
    var toolbarActions: ToolbarActions {
        .init(
            save: {
                print("old save, for recipe: \(recipeStore.recipe)")
                createNew ? saveNewRecipe() : saveChanges()
            },
            delete: { if !createNew { self.alertSwitch = true } },
            cancel: { createNew ?  dismissView() : cancelChanges() },
            option1: { if !createNew { self.groupSwitch = true } }
        )
    }
    
    // MARK: - Body
    var body: some View {
        
        VStack {
            EditableHeaderView(recipe: $recipeStore.recipe, editingEnabled: $editingEnabled, optionalDisplay: "create.display.title".localized)
                .environment(\.toolbarActions, toolbarActions)
                .onTapGesture {
                    hideKeyboard()
                }
            
            List {
                if !descriptionText.isEmpty || editingEnabled {
                    EditableDescriptionView(
                        descriptionText: $recipeStore.recipe.description,
                        prepText: $recipeStore.recipe.prepTime,
                        cookText: $recipeStore.recipe.cookTime,
                        editingEnabled: $editingEnabled,
                        optionalDisplay: "create.display.desc".localized
                    )
                    .onTapGesture {
                        hideKeyboard()
                    }
                }
                if !recipeStore.recipe.ingredients.isEmpty || editingEnabled {
                    EditableSectionView(
                        list: $recipeStore.recipe.ingredients,
                        isEditing: $editingEnabled,
                        headerText: "recipe.ingredients.title".localized,
                        deleteAction: { self.recipeStore.recipe.ingredients.remove(atOffsets: $0) },
                        addAction: { recipeStore.recipe.ingredients.insert("", at: 0) },
                        optionalDisplay: "recipe.ingredients.new".localized
                    )
                }
                if !recipeStore.recipe.instructions.isEmpty || editingEnabled {
                    EditableSectionView(
                        list: $recipeStore.recipe.instructions,
                        isEditing: $editingEnabled,
                        headerText: "recipe.instructions.title".localized,
                        numbered: true,
                        deleteAction: { self.recipeStore.recipe.instructions.remove(atOffsets: $0) },
                        addAction: { recipeStore.recipe.instructions.append("") },
                        optionalDisplay: "recipe.instructions.new".localized
                    )
                }
                
            }
            .alert("recipe.alert.delete.title".localized, isPresented: $alertSwitch) {
                Button("button.delete".localized, role: .destructive) {
                    deleteSelf()
                }
                Button("button.cancel".localized, role: .cancel){}
            } message: {
                Text("recipe.alert.delete.desc".localized)
            }
            .popover(isPresented: $groupSwitch) {
                if let recipeItem: RecipeItem = dataService.getItem(recipeStore.recipe.dataEntity) {
                    SelectGroupsView(
                        selectionAction: {
                            try? dataService.addToGroup(self.recipeStore.recipe, $0)
                            groupSwitch = false
                        },
                        cancelAction: {
                            groupSwitch = false
                        },
                        newRecipe: recipeItem
                    )
                }
            }
            .environment(\.editMode, .constant(editingEnabled ? EditMode.active : EditMode.inactive))
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                updateRecipe()
            }
        }
    }
    
}

extension RecipeView {

    @MainActor
    func saveChanges() {
        withAnimation {
            self.editingEnabled = false
        }
        self.recipeStore.recipe.description = self.descriptionText
        self.recipeStore.recipe.cookTime = self.cookText
        self.recipeStore.recipe.prepTime = self.prepText
        self.recipeStore.recipe.instructions.removeAll { $0 == "" }
        self.recipeStore.recipe.ingredients.removeAll { $0 == "" }
        try? dataService.update(&self.recipeStore.recipe)
    }
    
    func saveNewRecipe() {
        if recipeStore.recipe.title == "" { recipeStore.recipe.title = "recipe.title.new".localized }
        if recipeStore.recipe.instructions.contains("") { recipeStore.recipe.instructions.removeAll(where: {$0 == ""}) }
        if recipeStore.recipe.ingredients.contains("") { recipeStore.recipe.ingredients.removeAll(where: {$0 == ""}) }
        recipeStore.recipe.description = descriptionText
        recipeStore.recipe.prepTime = prepText
        recipeStore.recipe.cookTime = cookText
        print("about to save \(recipeStore.recipe)")
        let _ = try? dataService.save(self.recipeStore.recipe)
        dismissView()
    }
    
    func cancelChanges() {
        Task { @MainActor in
            withAnimation {
                self.editingEnabled = false
            }
        }
        let entity: RecipeItem? = dataService.objectWithId(self.recipeStore.recipe.dataEntity)
        self.recipeStore.recipe.title = entity?.title ?? self.recipeStore.recipe.title
        self.recipeStore.recipe.description = entity?.desc ?? ""
        if let data = entity?.photoData { self.recipeStore.recipe.img = .selected(data) }
        self.descriptionText = self.recipeStore.recipe.description.isEmpty ? self.descriptionText : self.recipeStore.recipe.description
        self.prepText = self.recipeStore.recipe.prepTime.isEmpty ? self.prepText : self.recipeStore.recipe.prepTime
        self.cookText = self.recipeStore.recipe.cookTime.isEmpty ? self.cookText : self.recipeStore.recipe.cookTime
        
        guard var ingredientArr = entity?.ingredients?.array as? [Ingredient] else { return }
        guard var instructionArr = entity?.instructions?.array as? [Instruction] else { return }
        ingredientArr = ingredientArr.filter { $0.value != nil }
        instructionArr = instructionArr.filter { $0.value != nil }
        
        self.recipeStore.recipe.ingredients = ingredientArr.map { $0.value! }
        self.recipeStore.recipe.instructions = instructionArr.map { $0.value! }
    }
    
    func deleteSelf() {
        try? dataService.delete(self.recipeStore.recipe)
        self.recipeStore.recipe.dataEntity = nil
        dismissView()
    }
    
//    func saveRecipe(recipe: Recipe) -> Recipe {
//        var newRecipe = recipe
//        newRecipe.dataEntity = try? dataService.save(recipe)?.objectID
//        return newRecipe
//    }
    
    func updateRecipe() {
        if screen == .search {
            if let item = try? dataService.findDuplicates(recipeStore.recipe) {
                var new = recipeStore.recipe
                new.dataEntity = item.objectID
                self.recipeStore.recipe = new
            } else {
                self.recipeStore.recipe.dataEntity = nil
            }
        }
    }
}
