//
//  RecipeView.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 7/17/23.
//

import SwiftUI
import CoreData

struct RecipeView: View {
    
    @Environment(\.dismiss) private var dismissView
    
    @StateObject var viewModel: RecipeViewModel
   
    
    // MARK: - Body
    var body: some View {
        
        VStack {
            EditableHeaderView(headerText: $viewModel.recipe.title,
                               isEditing: $viewModel.editingEnabled,
                               saveAction: { viewModel.saveChanges() },
                               cancelAction: { viewModel.cancelEditing() },
                               deleteAction: { viewModel.toggleDelete() },
                               imgUrl: viewModel.recipe.img,
                               siteUrl: viewModel.recipe.url)
            
            
            List {
                
                EditableDescriptionView(isEditing: $viewModel.editingEnabled,
                                        description: $viewModel.descriptionText,
                                        prepTime: viewModel.recipe.prepTime,
                                        cookTime: viewModel.recipe.cookTime)
                
                EditableSectionView(list: $viewModel.recipe.ingredients,
                                    isEditing: $viewModel.editingEnabled,
                                    headerText: "recipe.ingredients.title".localized,
                                    deleteAction: { viewModel.deleteFromIngr(offsets: $0) },
                                    addAction: { viewModel.recipe.ingredients.insert("", at: 0) },
                                    optionalDisplayValue: "recipe.ingredients.new".localized)
                
                EditableSectionView(list: $viewModel.recipe.instructions,
                                    isEditing: $viewModel.editingEnabled,
                                    headerText: "recipe.instructions.title".localized,
                                    numbered: true,
                                    deleteAction: { viewModel.deleteFromInst(offsets: $0) },
                                    addAction: { viewModel.recipe.instructions.insert("", at: 0) },
                                    optionalDisplayValue: "recipe.instructions.new".localized)
                
            }
            .alert("recipe.alert.delete.title".localized, isPresented: $viewModel.confirmationPopup) {
                Button("button.delete".localized, role: .destructive) {
                    viewModel.deleteSelf(dismissal: dismissView)
                }
                Button("button.cancel".localized, role: .cancel){}
            } message: {
                Text("recipe.alert.delete.desc".localized)
            }
            .environment(\.editMode, .constant(viewModel.editingEnabled ? EditMode.active : EditMode.inactive))
            
        }
    }
    
}
