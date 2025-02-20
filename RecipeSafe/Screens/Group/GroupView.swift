//
//  GroupView.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 8/10/23.
//

import SwiftUI

struct GroupView: View {
    
    @FetchRequest(
        sortDescriptors: [],
        predicate: NSPredicate(format: "group == nil")
    ) private var recipes: FetchedResults<RecipeItem>
    
    // MARK: - Environment
    @Environment(\.presentationMode) var dismissAction
    @Environment(\.services.groupData) var dataService
    
    @State var group: GroupModel
    @State var addRecipeSwitch: Bool = false
    @State var deleteGroupSwitch: Bool = false
    @State var editingEnabled: Bool = false
    @State var selectedRecipes: [RecipeItem] = []

    // MARK: - Body
    var body: some View {
        
        // MARK: - Header
        GroupHeaderImage(group: $group)
            .frame(maxHeight: 40)
            .editableToolbar(
                isEditing: $editingEnabled,
                save: { saveChanges() },
                delete: { toggleDelete() },
                cancel: { cancelChanges() }
            )
//            .toolbar {
////                EditableToolbar(
////                    isEditing: $editingEnabled,
////                    saveAction: saveChanges,
////                    cancelAction: cancelChanges,
////                    deleteAction: toggleDelete
////                )
//                EditableToolbar(isEditing: $editingEnabled)
//            }
        
        // MARK: - Recipes
        TabbedList(textFieldTitle: $group.title,
                   editing: $editingEnabled,
                   textFieldPrompt: "group.title.prompt".localized) {
            
            ForEach(group.recipes) { recipe in
                if let recipeModel = Recipe(dataItem: recipe) {
                    NavigationLink {
                        // RecipeView(viewModel: RecipeViewModel(recipe: recipeModel, screen: .groups))
                        RecipeView(recipe: recipeModel, screen: .groups)
                    } label: {
                        Text(recipe.title ?? "")
                    }
                }
            }.onDelete { offsets in
                removeRecipe(at: offsets)
            }
            .onMove { start, end in
                moveRecipes(from: start, to: end)
            }
            if !recipes.isEmpty {
                Section {
                    HStack {
                        Spacer()
                        Button {
                            addRecipeSwitch = true
                        } label: {
                            Image(systemName: "plus.circle")
                                .foregroundColor(.primary)
                        }
                        Spacer()
                    }
                } header: {
                    Text("group.list.add".localized + group.title)
                }
            } else if group.recipes.isEmpty {
                EmptyGroupView()
            }
        }
        .environment(\.editMode, .constant(editingEnabled ? EditMode.active : EditMode.inactive))
        .navigationBarTitleDisplayMode(.inline)
        
        // MARK: - Popups
        .popover(isPresented: $addRecipeSwitch) {
            AddRecipePopover(selectedRecipes: $selectedRecipes,
                             saveAction: { saveAddedRecipes() },
                             recipes: Array(recipes))
        }
        .alert("group.alert.delete".localized, isPresented: $deleteGroupSwitch) {
            Button("button.delete".localized, role: .destructive) {
                deleteSelf()
            }
        }
    }
}

extension GroupView {
    
    func toggleDelete() {
        self.deleteGroupSwitch = true
    }
    
    func deleteSelf() {
        self.dataService.viewContext.delete(group.dataEntity)
        dismissAction.wrappedValue.dismiss()
    }
    
    func saveChanges() {
        withAnimation {
            self.editingEnabled = false
        }
        try? self.dataService.update(group)
    }
    
    func cancelChanges() {
        withAnimation {
            self.editingEnabled = false
        }
        if let title = group.dataEntity.title {
            self.group.title = title
        }
        if let recipes = group.dataEntity.recipes?.array as? [RecipeItem] {
            self.group.recipes = recipes
        }
    }
    
    func removeRecipe(at offsets: IndexSet) {
        if !editingEnabled {
            offsets.forEach {
                self.group.recipes[$0].group = nil
            }
        }
        self.group.recipes.remove(atOffsets: offsets)
        if !editingEnabled {
            try? dataService.update(group)
        }
    }
    
    func moveRecipes(from start: IndexSet, to end: Int) {
        self.group.recipes.move(fromOffsets: start, toOffset: end)
    }
    
    func saveAddedRecipes() {
        self.addRecipeSwitch = false
        self.group.recipes.append(contentsOf: self.selectedRecipes)
        self.saveChanges()
        self.selectedRecipes = []
    }
}
