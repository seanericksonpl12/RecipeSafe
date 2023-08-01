//
//  CreateRecipeView.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 7/31/23.
//

import SwiftUI
import PhotosUI

struct CreateRecipeView: View {
    
    @StateObject private var viewModel = CreateRecipeViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            EditableHeaderView(recipe: $viewModel.recipe,
                               isEditing: $viewModel.editing,
                               saveAction: {viewModel.saveChanges(dismiss)},
                               cancelAction: {viewModel.cancel(dismiss)},
                               optionalDisplay: "create.display.title".localized)
            
            List {
                
                EditableDescriptionView(isEditing: $viewModel.editing,
                                        description: $viewModel.descriptionText,
                                        prepTime: viewModel.recipe.prepTime,
                                        cookTime: viewModel.recipe.cookTime,
                                        optionalDisplay: "create.display.desc".localized)
                
                EditableSectionView(list: $viewModel.recipe.ingredients,
                                    isEditing: $viewModel.editing,
                                    headerText: "recipe.ingredients.title".localized,
                                    deleteAction: { viewModel.deleteFromIngr(offsets: $0) },
                                    addAction: { viewModel.recipe.ingredients.insert("", at: 0) },
                                    optionalDisplay: "recipe.ingredients.new".localized)
                
                EditableSectionView(list: $viewModel.recipe.instructions,
                                    isEditing: $viewModel.editing,
                                    headerText: "recipe.instructions.title".localized,
                                    numbered: true,
                                    deleteAction: { viewModel.deleteFromInst(offsets: $0) },
                                    addAction: { viewModel.recipe.instructions.append("") },
                                    optionalDisplay: "recipe.instructions.new".localized)
                
            }
            .alert("create.alert.title".localized, isPresented: $viewModel.addTitleAlert) {
                Button("button.ok".localized) {
                    viewModel.addTitleAlert = false
                }
            }
            .environment(\.editMode, .constant(viewModel.editing ? EditMode.active : EditMode.inactive))
        }
    }
}

struct CreateRecipeView_Previews: PreviewProvider {
    static var previews: some View {
        CreateRecipeView()
    }
}
