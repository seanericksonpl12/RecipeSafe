//
//  LaunchScreen.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 9/30/24.
//
import UIKit
import SwiftUI

struct LaunchScreen: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> some UIViewController {
        let storyboard = UIStoryboard(name: "Launch Screen", bundle: Bundle.main)
        let viewController = storyboard.instantiateViewController(withIdentifier: "LaunchScreen")
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    }
}

#Preview {
    LaunchScreen()
}
