//
//  GroupView.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 8/10/23.
//

import SwiftUI

struct GroupView: View {
    
    @Environment(\.dismiss) var dismissAction
    
    @StateObject var viewModel: GroupViewModel
    
    var body: some View {
        NavigationStack {
            HStack {
                Spacer()
                TextField("", text: $viewModel.group.title, prompt: Text("group.title.prompt".localized), axis: .vertical)
                    .font(.title)
                    .padding(.leading)
                    .padding(.top)
                    .fontWeight(.heavy)
                    .disabled(!viewModel.editingEnabled)
                Spacer()
            }
            .editableToolbar(isEditing: $viewModel.editingEnabled,
                             saveAction: { viewModel.saveChanges() },
                             cancelAction: { viewModel.cancelChanges() },
                             deleteAction: {viewModel.toggleDelete() })
            List {
                ForEach(viewModel.group.recipes) { recipe in
                    if let recipeModel = Recipe(dataItem: recipe) {
                        NavigationLink {
                            RecipeView(viewModel: RecipeViewModel(recipe: recipeModel))
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
            }
            
        }
        .environment(\.editMode, .constant(viewModel.editingEnabled ? EditMode.active : EditMode.inactive))
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
