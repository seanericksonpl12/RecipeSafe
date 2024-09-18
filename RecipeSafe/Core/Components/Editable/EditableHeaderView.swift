//
//  EditableHeaderView.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 7/25/23.
//

import SwiftUI
import PhotosUI

struct EditableHeaderView<T: EditableRecipeModel>: View {
    
    // MARK: - Wrapped Properties
    @State private var photoItem: PhotosPickerItem?
    @State private var tempPhoto: ImageData = .none
    
    @EnvironmentObject var viewModel: T

    // MARK: - Properties
    var optionalDisplay: String?
    
    // MARK: - Body
    var body: some View {
        HStack {
            Spacer()

            PhotosPicker(selection: $photoItem, matching: .images) {
                IconImage(isEditing: $viewModel.editingEnabled, img: $tempPhoto)
            }
            .onAppear {
                self.tempPhoto = viewModel.recipe.img
            }
            .onChange(of: photoItem) { _ in
                pickPhoto()
            }
            .disabled(!viewModel.editingEnabled)
            
            TextField("", text: $viewModel.recipe.title, prompt: Text(optionalDisplay ?? ""), axis: .vertical)
                .font(.title)
                .fontWeight(.heavy)
                .padding()
                .disabled(!viewModel.editingEnabled)
            Spacer()
        }
        .toolbar {
            if viewModel.recipe.dataEntity == nil {
                SaveableToolbar(save: { viewModel.recipe = viewModel.saveRecipe(recipe: viewModel.recipe) })
            } else {
                EditableToolbar(
                    isEditing: $viewModel.editingEnabled,
                    saveAction: { viewModel.recipe.img = tempPhoto; viewModel.saveAction() },
                    cancelAction: { tempPhoto = viewModel.recipe.img; viewModel.cancelAction() },
                    deleteAction: viewModel.deleteAction,
                    alternateAction: viewModel.recipe.dataEntity?.group == nil ? viewModel.groupAction : {},
                    urlLink: viewModel.recipe.url,
                    alternateText: viewModel.recipe.dataEntity?.group == nil ? "recipe.group.add".localized : nil
                )
            }
        }
    }
    
    // MARK: - Photo Selection
    private func pickPhoto() {
        photoItem?.loadTransferable(type: Data.self) { result in
            if let data = try? result.get() {
                Task { @MainActor in
                    tempPhoto = .selected(data)
                }
            }
        }
    }
    
}
