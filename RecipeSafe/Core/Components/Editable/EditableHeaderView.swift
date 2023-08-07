//
//  EditableHeaderView.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 7/25/23.
//

import SwiftUI
import PhotosUI

struct EditableHeaderView: View {
    
    // MARK: - Wrapped Properties
    @Binding var recipe: Recipe
    @Binding var isEditing: Bool
    @State private var photoItem: PhotosPickerItem?
    
    // MARK: - Actions
    var saveAction: () -> Void = {}
    var cancelAction: () -> Void = {}
    var deleteAction: () -> Void = {}
    
    var optionalDisplay: String?
    
    // MARK: - Body
    var body: some View {
        HStack {
            Spacer()
            // MARK: - Thumbnail Image
            PhotosPicker(selection: $photoItem, matching: .images) {
                if let data = recipe.photoData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: 70, maxHeight: 70)
                        .clipShape(Circle())
                        .padding(.leading)
                } else if let url = recipe.img {
                    AsyncImage(url: url) { img in
                        img.resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxWidth: 70, maxHeight: 70)
                            .clipShape(Circle())
                    } placeholder: {
                        LoadingView()
                            .frame(maxWidth: 70, maxHeight: 70)
                    }
                } else if isEditing {
                    Image(systemName: "plus.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: 70, maxHeight: 70)
                        .clipShape(Circle())
                        .padding(.leading)
                }
            }
            .onChange(of: photoItem) { _ in
                pickPhoto()
            }
            .disabled(!isEditing)
            
            // MARK: - Title
            TextField("", text: $recipe.title, prompt: Text(optionalDisplay ?? ""), axis: .vertical)
                .font(.title)
                .fontWeight(.heavy)
                .padding()
                .disabled(!isEditing)
            Spacer()
        }
        .editableToolbar(isEditing: $isEditing,
                         url: recipe.url,
                         saveAction: saveAction,
                         cancelAction: cancelAction,
                         deleteAction: deleteAction)
    }
    
    // MARK: - Photo Selection
    private func pickPhoto() {
        photoItem?.loadTransferable(type: Data.self) { result in
            if let data = try? result.get() {
                DispatchQueue.main.async {
                    self.recipe.photoData = data
                }
            }
        }
    }
    
}
