//
//  CreateRecipeMenu.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 2/24/25.
//

import SwiftUI
import PhotosUI
import Dependencies

struct CreateRecipeMenuView: View {
    
    @Dependency(\.analyticsService) var analytics
    
    let imageCompressionQuality: CGFloat = 0.25
    
    @Binding var createFromScratch: Bool
    @Binding var photoData: Data?
    @State var selectedPhoto: PhotosPickerItem?
    @State var capturedPhoto: UIImage?
    @State var showingPhotosPicker: Bool = false
    @State var showingCamera: Bool = false
    
    var body: some View {
        Menu {
            Button {
                createFromScratch = true
                analytics.trackAction(.tappedCreateNewRecipe)
            } label: {
                Label("Create", systemImage: "square.and.pencil")
            }
            Button {
                showingCamera = true
                analytics.trackAction(.tappedCreateNewRecipeFromCamera)
            } label: {
                Label("Camera", systemImage: "camera.viewfinder")
            }
            Button {
                showingPhotosPicker = true
                analytics.trackAction(.tappedCreateNewRecipeFromPhotos)
            } label: {
                Label("Photos", systemImage: "photo.on.rectangle.angled")
            }
        } label: {
            Image(systemName: "plus")
        }
        .sheet(isPresented: $showingCamera) {
          CameraView { capturedPhoto = $0 }
        }
        .photosPicker(isPresented: $showingPhotosPicker, selection: $selectedPhoto, matching: .any(of: [.images, .screenshots, .livePhotos]))
        .onChange(of: selectedPhoto) { _, newPhoto in
            loadSelectedPhoto(newPhoto)
        }
        .onChange(of: capturedPhoto) { _, newPhoto in
            loadCameraPhoto(newPhoto)
        }
    }
    
    func loadSelectedPhoto(_ item: PhotosPickerItem?) {
        self.selectedPhoto = nil
        guard let item else {
            self.photoData = nil
            return
        }
        Task { @MainActor in
            if let data = try await item.loadTransferable(type: Data.self), let uiImage = UIImage(data: data) {
                self.photoData = FileUtility.compressImage(image: uiImage, toSize: 40000)
            }
        }
    }
    
    func loadCameraPhoto(_ item: UIImage?) {
        self.capturedPhoto = nil
        guard let item else {
            self.photoData = nil
            return
        }
        
        Task { @MainActor in
            self.photoData = FileUtility.compressImage(image: item, toSize: 40000)
        }
    }
}
