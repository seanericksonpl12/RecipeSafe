//
//  RecipeView.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 7/17/23.
//

import SwiftUI
import CoreData

struct RecipeView<T: EditableRecipeModel>: View {
    
    // MARK: - Environment
    @Environment(\.dismiss) private var dismissView
    @Environment(\.services.recipeData.getItem) var getRecipeItem
    
    // MARK: - ViewModel
    @StateObject var viewModel: T
    
    // MARK: - Body
    var body: some View {
        
        VStack {
            EditableHeaderView<T>(optionalDisplay: "create.display.title".localized)
                .environmentObject(viewModel)
                .onTapGesture {
                    hideKeyboard()
                }
            
            List {
                if !viewModel.descriptionText.isEmpty {
                    EditableDescriptionView<T>(optionalDisplay: "create.display.desc".localized)
                        .environmentObject(viewModel)
                        .onTapGesture {
                            hideKeyboard()
                        }
                }
                if !viewModel.recipe.ingredients.isEmpty || viewModel.editingEnabled {
                    EditableSectionView(list: $viewModel.recipe.ingredients,
                                        isEditing: $viewModel.editingEnabled,
                                        headerText: "recipe.ingredients.title".localized,
                                        deleteAction: { viewModel.deleteFromIngr(offsets: $0) },
                                        addAction: { viewModel.recipe.ingredients.insert("", at: 0) },
                                        optionalDisplay: "recipe.ingredients.new".localized)
                }
                if !viewModel.recipe.instructions.isEmpty || viewModel.editingEnabled {
                    EditableSectionView(list: $viewModel.recipe.instructions,
                                        isEditing: $viewModel.editingEnabled,
                                        headerText: "recipe.instructions.title".localized,
                                        numbered: true,
                                        deleteAction: { viewModel.deleteFromInst(offsets: $0) },
                                        addAction: { viewModel.recipe.instructions.append("") },
                                        optionalDisplay: "recipe.instructions.new".localized)
                }
                
            }
            .alert("recipe.alert.delete.title".localized, isPresented: $viewModel.alertSwitch) {
                Button("button.delete".localized, role: .destructive) {
                    viewModel.deleteSelf()
                }
                Button("button.cancel".localized, role: .cancel){}
            } message: {
                Text("recipe.alert.delete.desc".localized)
            }
            .popover(isPresented: $viewModel.groupSwitch) {
                if let recipeItem: RecipeItem = getRecipeItem(viewModel.recipe.dataEntity) {
                    SelectGroupsView(selectionAction: { viewModel.addToGroup($0); viewModel.groupSwitch = false },
                                     cancelAction: { viewModel.groupSwitch = false },
                                     newRecipe: recipeItem
                    )
                }
            }
            .environment(\.editMode, .constant(viewModel.editingEnabled ? EditMode.active : EditMode.inactive))
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.updateRecipe()
                viewModel.setup(dismiss: dismissView)
            }
        }
    }
    
}
