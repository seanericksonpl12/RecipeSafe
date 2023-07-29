//
//  LottieView.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 7/24/23.
//

import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    // MARK: - Properties
    var animationName: String
    var speed: CGFloat = 1
    var colorKeyPath: String = "**.Ellipse 1.Stroke 1.Color"
    var logKeyPaths: Bool = false
    @Environment(\.colorScheme) var colorMode
    
    // MARK: - UIKit Adaptors
    func makeUIView(context: UIViewRepresentableContext<LottieView>) -> UIView {
        let view = UIView(frame: .zero)
        let animationView = LottieAnimationView(asset: animationName)
        let keyPath = AnimationKeypath(keypath: colorKeyPath)
        let color = ColorValueProvider(UIColor.white.lottieColorValue)
        
        if logKeyPaths {
            animationView.logHierarchyKeypaths()
        }
        if self.colorMode == .dark {
            animationView.setValueProvider(color, keypath: keyPath)
        }
        animationView.contentMode = .scaleAspectFit
        animationView.play()
        animationView.loopMode = .loop
        animationView.animationSpeed = speed
        animationView.sizeThatFits(CGSize(width: 50, height: 50))
        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)
        NSLayoutConstraint.activate([
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor),
        ])
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: UIViewRepresentableContext<LottieView>) {
    }
}
