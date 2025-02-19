//
//  EditableHeaderView.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 7/25/23.
//

import SwiftUI
import PhotosUI

struct EditableHeaderView<T: EditableRecipeModel>: View {
    
    @FetchRequest(
        sortDescriptors: [],
        animation: nil) private var results: FetchedResults<ShoppingListItem>
    
    // MARK: - Wrapped Properties
    @State private var photoItem: PhotosPickerItem?
    @State private var tempPhoto: ImageData = .none
    var dataManager: DataManager = DataManager.shared
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
            .onChange(of: photoItem) {
                pickPhoto()
            }
            .onChange(of: Array(results)) {}
            .disabled(!viewModel.editingEnabled)
            
            TextField("", text: $viewModel.recipe.title, prompt: Text(optionalDisplay ?? ""), axis: .vertical)
                .font(.title)
                .fontWeight(.heavy)
                .padding()
                .disabled(!viewModel.editingEnabled)
            Spacer()
        }
        .toolbar {
            let dataEntity: RecipeItem? = dataManager.object(with: viewModel.recipe.dataEntity)
                EditableToolbar(
                    isEditing: $viewModel.editingEnabled,
                    saveAction: { viewModel.recipe.img = tempPhoto; viewModel.saveAction() },
                    cancelAction: { tempPhoto = viewModel.recipe.img; viewModel.cancelAction() },
                    deleteAction: viewModel.deleteAction,
                    option1Action: dataEntity?.group == nil ? viewModel.groupAction : {},
                    option2Action: { dataManager.toggleShoppingList(recipe: dataEntity) },
                    urlLink: viewModel.recipe.url,
                    option1Text: dataEntity?.group == nil ? "recipe.group.add".localized : nil,
                    option2Text: dataManager.isInShoppingList(dataEntity) ? "Remove from Grocery List" : "Add to grocery list"
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
