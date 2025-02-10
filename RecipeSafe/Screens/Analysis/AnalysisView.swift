//
//  AnalysisView.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 2/3/25.
//

import SwiftUI
import PhotosUI

struct AnalysisView: View {
    
    @Service var dataManager: DataManager!
    @Service var networkManager: NetworkManager!
    
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var selectedImage: PhotosPickerItem?
    @State private var cameraImage: UIImage?
    @State private var cgImage: CGImage?
    @State private var recipeImage: ImageData?
    @State private var isImagePickerDisplay = false
    @State private var imageData: Data?
    @State private var isLoading: Bool = false
    @State private var navPath: NavigationPath = .init()
    @State private var showEvent: Bool = false
    @State private var hideTabBar: Bool = true
    @State private var visionModel: VisionRecipeViewModel?
    
    var body: some View {
        NavigationStack(path: $navPath) {
            VStack {
                PhotosPicker(selection: $selectedImage) {
                    if let recipeImage, case let .selected(data) = recipeImage, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(Circle())
                            .frame(width: 300, height: 300)
                    } else {
                        Image(systemName: "snow")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(Circle())
                            .frame(width: 300, height: 300)
                    }
                }
                .onChange(of: selectedImage) {
                    pickPhoto()
                }
                Button("Camera") {
                    self.sourceType = .camera
                    self.isImagePickerDisplay.toggle()
                }.padding()
                
                if isLoading {
                    ProgressView()
                } else if let data = self.imageData {
                    Button("Send Image") {
                        Task {
                            try await makeRequest(data)
                        }
                    }
                }
            }
            .navigationBarTitle("Demo")
            .sheet(isPresented: self.$isImagePickerDisplay) {
                CustomRecipeImagePickerView(selectedImage: self.$cameraImage, sourceType: .camera)
            }
            .navigationDestination(for: Recipe.self) { recipe in
                if let viewModel = self.visionModel {
                    RecipeView(viewModel: viewModel)
                        .toolbar(self.hideTabBar ? .hidden : .automatic, for: .tabBar)
                        .temporaryOverlay(isPresented: $showEvent, duration: 1.5) {
                            EventIndicatorAlert(text: "Recipe Saved!")
                        }
                }
            }
        }
    }
    
    private func pickPhoto() {
        selectedImage?.loadTransferable(type: Data.self) { result in
            if let data = try? result.get(), let uiImage = UIImage(data: data), let imgData = uiImage.jpegData(compressionQuality: 0.2) {
                if let cg = uiImage.cgImage {
                    self.cgImage = cg
                }
                self.imageData = imgData
                print("image original size: \(data.count)")
                print("compressed size: \(imgData.count)")
                Task { @MainActor in
                    recipeImage = .selected(imgData)
                }
            }
        }
    }
    
    private func makeRequest(_ data: Data) async throws {
        self.isLoading = true
        defer { self.isLoading = false }
        
        let request = try RecipeAnalysisRequest(imageData: data)
        let response = await networkManager.executeRequest(request: request, retries: 0)
        
        switch response {
        case .success(let success):
            print("got response: \(success)")
            if let title = success.title, let ingredients = success.ingredients, let instructions = success.instructions {
                let recipe = Recipe(title: title, description: success.description, ingredients: ingredients, instructions: instructions, img: .none, url: nil, prepTime: nil, cookTime: nil)
                print("created recipe: \(recipe)")
                self.visionModel = VisionRecipeViewModel(recipe: recipe) {
                    self.saveRecipe(recipe)
                } onCancel: {
                    navPath = .init()
                }
                self.navPath.append(recipe)
            }
        case .failure(let failure):
            print("failed with error: \(failure)")
        }
    }
    
    private func saveRecipe(_ recipe: Recipe) {
        if let _ = dataManager.saveItem(recipe) {
            withAnimation {
                self.visionModel?.editingEnabled = false
            }
            displaySavedIcon()
            self.hideTabBar = false
        }
    }
    
    private func cancelRecipe() {
        self.navPath = .init()
        self.imageData = nil
        self.selectedImage = nil
    }
    
    private func displaySavedIcon() {
        withAnimation {
            self.showEvent = true
        }
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            withAnimation {
                self.showEvent = false
            }
        }
    }
}
