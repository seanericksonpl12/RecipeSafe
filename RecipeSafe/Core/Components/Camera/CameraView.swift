//
//  CameraView.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 2/24/25.
//

import SwiftUI

struct CameraView: UIViewControllerRepresentable {
  
  @Environment(\.presentationMode) private var presentationMode
  let imagePicked: (UIImage) -> Void
  
  func makeUIViewController(context: Context) -> UIImagePickerController {
    let picker = UIImagePickerController()
    picker.sourceType = .camera
    picker.delegate = context.coordinator
    return picker
  }
  
  func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
  
  func makeCoordinator() -> Coordinator {
    Coordinator(
      onDismiss: { self.presentationMode.wrappedValue.dismiss() },
      onImagePicked: imagePicked
    )
  }
  
  final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    private let onDismiss: () -> Void
    private let onImagePicked: (UIImage) -> Void
    
    init(
      onDismiss: @escaping () -> Void,
      onImagePicked: @escaping (UIImage) -> Void
    ) {
      self.onDismiss = onDismiss
      self.onImagePicked = onImagePicked
    }
    
    func imagePickerController(
      _ picker: UIImagePickerController,
      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
      if let image = info[.originalImage] as? UIImage {
        self.onImagePicked(image)
      }
      self.onDismiss()
    }
    
    func imagePickerControllerDidCancel(_: UIImagePickerController) {
      self.onDismiss()
    }
  }
}
