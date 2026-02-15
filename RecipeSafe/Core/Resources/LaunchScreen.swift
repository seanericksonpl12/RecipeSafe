//
//  LaunchScreen.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 9/30/24.
//
import UIKit
import Lottie
import SwiftUI
import Combine

struct LaunchScreen: UIViewControllerRepresentable {
    
    @Environment(\.colorScheme) var colorScheme
    @Binding var didFinishPlayingAnimation: Bool
    let playAnimation: Bool
    
    private let animationCutTime: UInt64 = 1_200_000_000
    private let storyboardName = "Launch Screen"
    private let storyboardId = "LaunchScreen"
    
    func makeUIViewController(context: Context) -> LaunchScreenViewController {
        let storyboard = UIStoryboard(name: storyboardName, bundle: Bundle.main)
        
        guard let viewController = storyboard.instantiateViewController(withIdentifier: storyboardId) as? LaunchScreenViewController else {
            didFinishPlayingAnimation = true
            return LaunchScreenViewController()
        }
        viewController.colorScheme = colorScheme
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
    
    func updateUIViewController(_ uiViewController: LaunchScreenViewController, context: Context) {
        if self.playAnimation {
            uiViewController.playAnimation()
        }
    }
}

class LaunchScreenViewController: UIViewController {
    
    @IBOutlet weak var animationView: LottieAnimationView?
    var didFinishAnimationAction: () -> Void = {}
    var animationStarting: () -> Void = {}
    var colorScheme: ColorScheme = .light
    var playingAnimation = false
    
    override func viewDidLoad() {
        self.view.backgroundColor = .systemBackground
        animationView?.animation = LottieAnimation.named(colorScheme == .light ? "LockAnimation" : "LockAnimationDark")
        super.viewDidLoad()
    }
    
    func playAnimation() {
        if playingAnimation { return }
        playingAnimation = true
        animationView?.play { [weak self] _ in
            self?.didFinishAnimationAction()
        }
        animationStarting()
    }
}
