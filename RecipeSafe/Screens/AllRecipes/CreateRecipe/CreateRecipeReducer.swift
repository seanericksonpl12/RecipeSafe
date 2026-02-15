import ComposableArchitecture
import Foundation
import PhotosUI
import SwiftUI

@Reducer
struct CreateRecipeReducer: Sendable {
  
  var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .binding(\.selectedPhoto):
        if let image = state.selectedPhoto {
          return .run { send in
            if let data = try await loadSelectedImage(image) {
              await send(.delegate(.photoDataLoaded(data)))
            }
          }
        } else {
          return .none
        }
      case .binding(\.capturedPhoto):
        if let image = state.capturedPhoto {
          return .run { send in
            if let data = try await loadCameraImage(image) {
              await send(.delegate(.photoDataLoaded(data)))
            }
          }
        } else {
          return .none
        }
      case .createTapped:
        return .none
      case .cameraTapped:
        return .none
      case .photosTapped:
        return .none
      default:
        return .none
      }
    }
  }
  
  private func loadSelectedImage(_ image: PhotosPickerItem) async throws -> Data? {
    if let data = try await image.loadTransferable(type: Data.self), let uiImage = UIImage(data: data) {
      return FileUtility.compressImage(image: uiImage, toSize: 40000)
    }
    return nil
  }
  
  private func loadCameraImage(_ image: UIImage) async throws -> Data? {
    FileUtility.compressImage(image: image, toSize: 40000)
  }
  
  @ObservableState
  struct State: Equatable, Sendable {
    let imageCompressionQuality: CGFloat = 0.25
    
    var photoData: Data?
    var selectedPhoto: PhotosPickerItem?
    var showingPhotosPicker: Bool = false
    var showingCamera: Bool = false
    
    var capturedPhoto: UIImage?
  }
  
  enum Action: Equatable, Sendable, BindableAction {
    case binding(BindingAction<State>)
    case createTapped
    case cameraTapped
    case photosTapped
    
    case delegate(DelegateAction)
  }
  
  enum DelegateAction: Equatable, Sendable {
    case photoDataLoaded(Data)
  }
}
