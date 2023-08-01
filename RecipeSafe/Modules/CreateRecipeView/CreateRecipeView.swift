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
            HStack {
                Spacer()
                Button("button.save".localized) {
                    viewModel.saveChanges(dismiss)
                }
                .padding(.top)
                .padding(.trailing)
                Button("button.cancel".localized, role: .cancel) {
                    viewModel.cancel(dismiss)
                }
                .padding(.trailing)
                .padding(.top)
            }
            HStack {
                PhotosPicker(selection: $viewModel.photoItem, matching: .images) {
                    if let image = viewModel.photo {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxWidth: 70, maxHeight: 70)
                            .clipShape(Circle())
                            .padding(.leading)
                    } else {
                        Image(systemName: "plus.circle")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxWidth: 70, maxHeight: 70)
                            .clipShape(Circle())
                            .padding(.leading)
                    }
                }
                .onChange(of: viewModel.photoItem) { _ in
                    viewModel.loadPhoto()
                }
                
                EditableHeaderView(headerText: $viewModel.recipe.title,
                                   isEditing: $viewModel.editing,
                                   imgUrl: viewModel.recipe.img,
                                   siteUrl: viewModel.recipe.url,
                                   optionalDisplay: "Title")
                Spacer()
                
            }
            .padding(.top, -20)
            
            List {
                
                EditableDescriptionView(isEditing: $viewModel.editing,
                                        description: $viewModel.descriptionText,
                                        prepTime: viewModel.recipe.prepTime,
                                        cookTime: viewModel.recipe.cookTime,
                                        optionalDisplay: "Description")
                
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
            .alert("Add a title before saving!", isPresented: $viewModel.addTitleAlert) {
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
