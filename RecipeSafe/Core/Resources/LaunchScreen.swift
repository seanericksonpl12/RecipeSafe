//
//  LaunchScreen.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 9/30/24.
//
import UIKit
import Lottie
import SwiftUI

struct LaunchScreen: UIViewControllerRepresentable {
    
    @Binding var didFinishPlayingAnimation: Bool
    
    private let animationCutTime: UInt64 = 1_200_000_000
    private let storyboardName = "Launch Screen"
    private let storyboardId = "LaunchScreen"
    
    func makeUIViewController(context: Context) -> LaunchScreenViewController {
        let storyboard = UIStoryboard(name: storyboardName, bundle: Bundle.main)
        
        guard let viewController = storyboard.instantiateViewController(withIdentifier: storyboardId) as? LaunchScreenViewController else {
            didFinishPlayingAnimation = true
            return LaunchScreenViewController()
        }
        
        viewController.didFinishAnimationAction = {
            didFinishPlayingAnimation = true
        }
        viewController.animationStarting = {
            Task {
                try await Task.sleep(nanoseconds: animationCutTime)
                withAnimation {
                    didFinishPlayingAnimation = true
                }
            }
        }
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}

class LaunchScreenViewController: UIViewController {
    
    @IBOutlet weak var animationView: LottieAnimationView?
    var didFinishAnimationAction: () -> Void = {}
    var animationStarting: () -> Void = {}
    
    override func viewDidLoad() {
        animationView?.animation = LottieAnimation.named("LockAnimation")
        animationView?.play { [weak self] _ in
            self?.didFinishAnimationAction()
        }
        
        super.viewDidLoad()
        animationStarting()
    }
}
