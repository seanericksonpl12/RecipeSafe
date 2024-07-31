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
    @State private var tempPhoto: ImageData
    
    // MARK: - Actions
    var saveAction: () -> Void = {}
    var cancelAction: () -> Void = {}
    var deleteAction: () -> Void = {}
    var groupAction: () -> Void = {}
    
    // MARK: - Properties
    var optionalDisplay: String?
    
    init(recipe: Binding<Recipe>, isEditing: Binding<Bool>, saveAction: @escaping () -> Void, cancelAction: @escaping () -> Void, deleteAction: @escaping () -> Void, groupAction: @escaping () -> Void, optionalDisplay: String? = nil) {
        self._recipe = recipe
        self._isEditing = isEditing
        self.tempPhoto = recipe.wrappedValue.img
        self.saveAction = saveAction
        self.cancelAction = cancelAction
        self.deleteAction = deleteAction
        self.groupAction = groupAction
        self.optionalDisplay = optionalDisplay
    }
    
    // MARK: - Body
    var body: some View {
        HStack {
            Spacer()

            PhotosPicker(selection: $photoItem, matching: .images) {
                IconImage(isEditing: $isEditing, img: $tempPhoto)
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
                         alternateLabel: recipe.dataEntity?.group == nil ? "recipe.group.add".localized : nil,
                         saveAction: { recipe.img = tempPhoto; saveAction() },
                         cancelAction: { tempPhoto = recipe.img; cancelAction() },
                         deleteAction: deleteAction,
                         alternateAction: recipe.dataEntity?.group == nil ? groupAction : {} )
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
