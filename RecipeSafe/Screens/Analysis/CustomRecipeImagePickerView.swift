//
//  CustomRecipeAnalysisPicker.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 2/3/25.
//


import SwiftUI

struct CustomRecipeImagePickerView: UIViewControllerRepresentable {
    
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var isPresented
    var sourceType: UIImagePickerController.SourceType
        
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = self.sourceType
        imagePicker.delegate = context.coordinator
        return imagePicker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        
    }

    // Connecting the Coordinator class with this struct
    func makeCoordinator() -> CustomRecipeImageCoordinator {
        return CustomRecipeImageCoordinator(picker: self)
    }
}
