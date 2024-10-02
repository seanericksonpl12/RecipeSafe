//
//  GroupView.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 8/10/23.
//

import SwiftUI

struct GroupView: View {
    
    // MARK: - Environment
    @Environment(\.presentationMode) var dismissAction
    @StateObject var viewModel: GroupViewModel
    
    // MARK: - Body
    var body: some View {
        
        // MARK: - Header
        GroupHeaderImage(group: $viewModel.group)
            .frame(maxHeight: 40)
            .toolbar {
                EditableToolbar(
                    isEditing: $viewModel.editingEnabled,
                    saveAction: viewModel.saveChanges,
                    cancelAction: viewModel.cancelChanges,
                    deleteAction: viewModel.toggleDelete
                )
            }
//            .editableToolbar(isEditing: $viewModel.editingEnabled,
//                             saveAction: { viewModel.saveChanges() },
//                             cancelAction: { viewModel.cancelChanges() },
//                             deleteAction: {viewModel.toggleDelete() })
        
        // MARK: - Recipes
        TabbedList(textFieldTitle: $viewModel.group.title,
                   editing: $viewModel.editingEnabled,
                   textFieldPrompt: "group.title.prompt".localized) {
            
            ForEach(viewModel.group.recipes) { recipe in
                if let recipeModel = Recipe(dataItem: recipe) {
                    NavigationLink {
                        RecipeView(viewModel: RecipeViewModel(recipe: recipeModel, screen: .groups))
                    } label: {
                        Text(recipe.title ?? "")
                    }
                }
            }.onDelete { offsets in
                viewModel.removeRecipe(at: offsets)
            }
            .onMove { start, end in
                viewModel.moveRecipes(from: start, to: end)
            }
            if !viewModel.getRecipes().isEmpty {
                Section {
                    HStack {
                        Spacer()
                        Button {
                            viewModel.addRecipeSwitch = true
                        } label: {
                            Image(systemName: "plus.circle")
                                .foregroundColor(.primary)
                        }
                        Spacer()
                    }
                } header: {
                    Text("group.list.add".localized + viewModel.group.title)
                }
            } else if viewModel.group.recipes.isEmpty {
                EmptyGroupView()
            }
        }
        .environment(\.editMode, .constant(viewModel.editingEnabled ? EditMode.active : EditMode.inactive))
        .navigationBarTitleDisplayMode(.inline)
        
        // MARK: - Popups
        .popover(isPresented: $viewModel.addRecipeSwitch) {
            AddRecipePopover(selectedRecipes: $viewModel.selectedRecipes,
                             saveAction: { viewModel.saveAddedRecipes() },
                             recipes: viewModel.getRecipes())
        }
        .alert("group.alert.delete".localized, isPresented: $viewModel.deleteGroupSwitch) {
            Button("button.delete".localized, role: .destructive) {
                viewModel.deleteSelf()
            }
        }
        .onAppear { viewModel.setUp(dismiss: dismissAction) }
    }
}
