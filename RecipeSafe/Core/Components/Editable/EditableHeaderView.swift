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
    var groupAction: () -> Void = {}
    
    var optionalDisplay: String?
    
    // MARK: - Body
    var body: some View {
        HStack {
            Spacer()

            PhotosPicker(selection: $photoItem, matching: .images) {
                IconImage(isEditing: $isEditing, img: $recipe.img)
            }
            .onChange(of: photoItem) { _ in
                pickPhoto()
            }
            .disabled(!isEditing)
            
            TextField("", text: $recipe.title, prompt: Text(optionalDisplay ?? ""), axis: .vertical)
                .font(.title)
                .fontWeight(.heavy)
                .padding()
                .disabled(!isEditing)
            Spacer()
        }
        .editableToolbar(isEditing: $isEditing,
                         url: recipe.url,
                         alternateLabel: "Add to Group",
                         saveAction: saveAction,
                         cancelAction: cancelAction,
                         deleteAction: deleteAction,
                         alternateAction: groupAction)
    }
    
    // MARK: - Photo Selection
    private func pickPhoto() {
        photoItem?.loadTransferable(type: Data.self) { result in
            if let data = try? result.get() {
                DispatchQueue.main.async {
                    self.recipe.img = .selected(data)
                }
            }
        }
    }
    
}
