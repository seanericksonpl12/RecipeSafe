import ComposableArchitecture
import SwiftUI

struct CreateRecipeView: View {
  
  @Bindable var store: StoreOf<CreateRecipeReducer>
  
  var body: some View {
    Menu {
        Button {
          store.send(.createTapped)
        } label: {
            Label("Create", systemImage: "square.and.pencil")
        }
        Button {
          store.send(.cameraTapped)
        } label: {
            Label("Camera", systemImage: "camera.viewfinder")
        }
        Button {
          store.send(.photosTapped)
        } label: {
            Label("Photos", systemImage: "photo.on.rectangle.angled")
        }
    } label: {
        Image(systemName: "plus")
    }
    .fullScreenCover(isPresented: $store.showingCamera) {
      CameraView { store.capturedPhoto = $0 }
    }
    .photosPicker(
      isPresented: $store.showingPhotosPicker,
      selection: $store.selectedPhoto,
      matching: .any(of: [.images, .screenshots, .livePhotos])
    )
  }
}
