//
//  EditableHeaderView.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 7/25/23.
//

import SwiftUI
import PhotosUI
import CoreData
import Dependencies

struct EditableHeaderView: View {
    
//    @Dependency(\.coreDataService) var coreDataService
//    let recipeManager = RecipeManager()
//    @Environment(\.toolbarActions) var actions
//    
//    private var dataService: ShoppingListDataService {
//        ShoppingListDataService(viewContext: PersistenceController.shared.container.viewContext)
//    }
    
    @Binding var recipe: Recipe
    @Binding var editingEnabled: Bool
    
    @State private var photoItem: PhotosPickerItem?
    @State private var tempPhoto: ImageData = .none

    // MARK: - Properties
    var optionalDisplay: String?
    
//
//    private var newToolbarActions: ToolbarActions {
//        let entity = recipeManager.getRecipe(for: recipe.dataEntity)
//        return ToolbarActions(
//            save: {
//                recipe.img = tempPhoto;
//                try? actions.save()
//            },
//            delete: actions.delete,
//            cancel: {
//                tempPhoto = recipe.img
//                try? actions.cancel()
//            },
//            option1: entity?.group == nil ? actions.option1 : { @Sendable @MainActor in },
//            option2: {
//                dataService.isInList(entity) ? try? dataService.removeRecipeFromList(entity) : try? dataService.addToList(entity)
//            }
//        )
//    }
//    
    // MARK: - Body
    var body: some View {
//        let entity = recipeManager.getRecipe(for: recipe.dataEntity)
        HStack {
            Spacer()

            PhotosPicker(selection: $photoItem, matching: .images) {
                IconImage(isEditing: editingEnabled, img: tempPhoto)
            }
            .onAppear {
                self.tempPhoto = recipe.img
            }
            .onChange(of: photoItem) {
                pickPhoto()
            }
            .disabled(!editingEnabled)
            
            TextField("", text: $recipe.title, prompt: Text(optionalDisplay ?? ""), axis: .vertical)
                .font(.title)
                .fontWeight(.heavy)
                .padding()
                .disabled(!editingEnabled)
            Spacer()
        }
//        .editableToolbar(
//            isEditing: $editingEnabled,
//            urlLink: recipe.url,
//            option1Text: entity?.group == nil ? "recipe.group.add".localized : nil,
//            option2Text: dataService.isInList(entity) ? "Remove from Grocery List" : "Add to Shopping List",
//            actions: newToolbarActions
//        )
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

#Preview {
    EditableHeaderView(recipe: .constant(Recipe(title: "ejklfs", description: "fdsafd", ingredients: [], instructions: [], img: .none, url: nil, prepTime: nil, cookTime: nil)), editingEnabled: .constant(true), optionalDisplay: nil)
        .environment(\.toolbarActions, .defaultValue)
}
