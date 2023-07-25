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
                               deleteAction: { viewModel.deleteSelf(dismissal: dismissView) },
                               imgUrl: viewModel.recipe.img,
                               siteUrl: viewModel.recipe.url)
            
            
            List {
                
                EditableDescriptionView(isEditing: $viewModel.editingEnabled,
                                        description: $viewModel.descriptionText,
                                        prepTime: viewModel.recipe.prepTime,
                                        cookTime: viewModel.recipe.cookTime)
                
                EditableSectionView(list: $viewModel.recipe.ingredients,
                                    isEditing: $viewModel.editingEnabled,
                                    headerText: "Ingredients",
                                    deleteAction: { viewModel.deleteFromIngr(offsets: $0) },
                                    addAction: { viewModel.recipe.ingredients.insert("", at: 0) },
                                    optionalDisplayValue: "new ingredient")
                
                EditableSectionView(list: $viewModel.recipe.instructions,
                                    isEditing: $viewModel.editingEnabled,
                                    headerText: "Instructions",
                                    numbered: true,
                                    deleteAction: { viewModel.deleteFromInst(offsets: $0) },
                                    addAction: { viewModel.recipe.instructions.insert("", at: 0) },
                                    optionalDisplayValue: "new instruction")
                
            }
            .environment(\.editMode, .constant(viewModel.editingEnabled ? EditMode.active : EditMode.inactive))
            
        }
    }
    
}

struct RecipeView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeView(viewModel: RecipeViewModel(recipe: Recipe(title: "", ingredients: [])))
    }
}
