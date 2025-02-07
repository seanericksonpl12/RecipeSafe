//
//  CustomRecipeImageCoordinator.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 2/3/25.
//

import UIKit

class CustomRecipeImageCoordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var picker: CustomRecipeImagePickerView
    
    init(picker: CustomRecipeImagePickerView) {
        self.picker = picker
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else { return }
        self.picker.selectedImage = selectedImage
        self.picker.isPresented.wrappedValue.dismiss()
    }
}
