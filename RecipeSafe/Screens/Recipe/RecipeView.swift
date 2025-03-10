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
    
    @State var recipe: Recipe
    @State var editingEnabled: Bool
    @State var alertSwitch: Bool = false
    @State var groupSwitch: Bool = false
    
    let screen: Screen
    let createNew: Bool
    
    init(recipe: Recipe, screen: Screen, createNew: Bool = false) {
        self.recipe = recipe
        self.screen = screen
        self.editingEnabled = createNew
        self.createNew = createNew
        if createNew {
            if self.recipe.ingredients.isEmpty { self.recipe.ingredients = [""] }
            if self.recipe.instructions.isEmpty { self.recipe.instructions = [""] }
        }
    }
    
    var toolbarActions: ToolbarActions {
        .init(
            save: {
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
            EditableHeaderView(recipe: $recipe, editingEnabled: $editingEnabled, optionalDisplay: "create.display.title".localized)
                .onTapGesture {
                    hideKeyboard()
                }
            
            List {
                if !recipe.description.isEmpty || editingEnabled {
                    EditableDescriptionView(
                        recipe: $recipe,
                        editingEnabled: $editingEnabled,
                        optionalDisplay: "create.display.desc".localized
                    )
                    .onTapGesture {
                        hideKeyboard()
                    }
                }
                if !recipe.ingredients.isEmpty || editingEnabled {
                    EditableSectionView(
                        list: $recipe.ingredients,
                        isEditing: $editingEnabled,
                        headerText: "recipe.ingredients.title".localized,
                        deleteAction: { self.recipe.ingredients.remove(atOffsets: $0) },
                        addAction: { recipe.ingredients.append("") },
                        optionalDisplay: "recipe.ingredients.new".localized
                    )
                }
                if !recipe.instructions.isEmpty || editingEnabled {
                    EditableSectionView(
                        list: $recipe.instructions,
                        isEditing: $editingEnabled,
                        headerText: "recipe.instructions.title".localized,
                        numbered: true,
                        deleteAction: { self.recipe.instructions.remove(atOffsets: $0) },
                        addAction: { recipe.instructions.append("") },
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
                if let recipeItem: RecipeItem = dataService.getItem(recipe.dataEntity) {
                    SelectGroupsView(
                        selectionAction: {
                            try? dataService.addToGroup(self.recipe, $0)
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
        .environment(\.toolbarActions, toolbarActions)
        .pageLoad(.recipe)
        .keepScreenAlive()
    }
    
}

extension RecipeView {

    @MainActor
    func saveChanges() {
        withAnimation {
            self.editingEnabled = false
        }
        self.recipe.instructions.removeAll { $0 == "" }
        self.recipe.ingredients.removeAll { $0 == "" }
        try? dataService.update(&self.recipe)
    }
    
    func saveNewRecipe() {
        if recipe.title == "" { recipe.title = "recipe.title.new".localized }
        if recipe.instructions.contains("") { recipe.instructions.removeAll(where: {$0 == ""}) }
        if recipe.ingredients.contains("") { recipe.ingredients.removeAll(where: {$0 == ""}) }
        print("about to save \(recipe)")
        let _ = try? dataService.save(self.recipe)
        dismissView()
    }
    
    func cancelChanges() {
        Task { @MainActor in
            withAnimation {
                self.editingEnabled = false
            }
        }
        let entity: RecipeItem? = dataService.objectWithId(self.recipe.dataEntity)
        self.recipe.title = entity?.title ?? self.recipe.title
        self.recipe.description = entity?.desc ?? ""
        if let data = entity?.photoData { self.recipe.img = .selected(data) }
        
        guard var ingredientArr = entity?.ingredients?.array as? [Ingredient] else { return }
        guard var instructionArr = entity?.instructions?.array as? [Instruction] else { return }
        ingredientArr = ingredientArr.filter { $0.value != nil }
        instructionArr = instructionArr.filter { $0.value != nil }
        
        self.recipe.ingredients = ingredientArr.map { $0.value! }
        self.recipe.instructions = instructionArr.map { $0.value! }
    }
    
    func deleteSelf() {
        try? dataService.delete(self.recipe)
        self.recipe.dataEntity = nil
        dismissView()
    }

    func updateRecipe() {
        if screen == .search {
            if let item = try? dataService.findDuplicates(recipe) {
                var new = recipe
                new.dataEntity = item.objectID
                self.recipe = new
            } else {
                self.recipe.dataEntity = nil
            }
        }
    }
}

#Preview {
    RecipeView(
        recipe: Recipe(
            title: "Venison Stew",
            description: "Tasty mock recipe with verison and stew",
            ingredients: [
                "1lb Vension chuck",
                "12 carrots",
                "one celery",
                "beef stock",
                "one onion"
            ],
            instructions: [
                "chop up celery, carrots and onion",
                "score venison chuck, and sear all sides - about 1 minute per side",
                "mix water and beef stock in a large pot and bring to a boil",
                "Reduce to simmer, add venison and vegetables and let simmer for about 45 minutes",
                "Let cool and enjoy!"
            ],
            img: .downloaded(URL(string:"https://www.thespruceeats.com/thmb/TJONzQm5Met1xI81mPWIk8r5XBQ=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/venison-stew-recipe-1375519-step-010-4521974d8b0e44c7b6f59f474e552bad.jpg")!),
            url: nil,
            prepTime: "30 mn",
            cookTime: "1 hr"),
        screen: .allRecipes,
        createNew: false
    )
    .injectServices()
    .environment(\.toolbarActions, .defaultValue)
    .navigationBarTitleDisplayMode(.inline)
}
