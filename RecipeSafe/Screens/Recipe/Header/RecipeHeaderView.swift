import ComposableArchitecture
import PhotosUI
import SwiftUI

struct RecipeHeaderView: View {
  
  @Binding var recipe: Recipe
  let editingEnabled: Bool

  @State private var photoItem: PhotosPickerItem?
  @State private var tempPhoto: ImageData = .none
  var optionalDisplay: String?
  
  var body: some View {
    HStack {
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
