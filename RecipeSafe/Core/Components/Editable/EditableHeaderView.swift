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
    @Service var dataManager: DataManager!
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
                EditableToolbar(
                    isEditing: $viewModel.editingEnabled,
                    saveAction: { viewModel.recipe.img = tempPhoto; viewModel.saveAction() },
                    cancelAction: { tempPhoto = viewModel.recipe.img; viewModel.cancelAction() },
                    deleteAction: viewModel.deleteAction,
                    option1Action: viewModel.recipe.dataEntity?.group == nil ? viewModel.groupAction : {},
                    option2Action: { dataManager.addRecipeToShoppingList(recipe: viewModel.recipe) },
                    urlLink: viewModel.recipe.url,
                    option1Text: viewModel.recipe.dataEntity?.group == nil ? "recipe.group.add".localized : nil,
                    option2Text: dataManager.isInShoppingList(recipe: viewModel.recipe) ? "Remove from Grocery List" : "Add to grocery list"
                )
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
