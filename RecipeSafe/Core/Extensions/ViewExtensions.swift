//
//  ViewExtensions.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 7/25/23.
//

import Foundation
import SwiftUI
import Combine

// MARK: - Hide Keyboard


private struct KeyboardListenerModifier: ViewModifier {
    
    @State var isKeyboardShowing:Bool = false
    
    private var keyboardPublisher: AnyPublisher<Bool, Never> {
        Publishers.Merge(
                NotificationCenter
                    .default
                    .publisher(for: UIResponder.keyboardWillShowNotification)
                    .map { _ in true },
                NotificationCenter
                    .default
                    .publisher(for: UIResponder.keyboardWillHideNotification)
                    .map { _ in false }
            )
            .debounce(for: .seconds(0.1), scheduler: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    func body(content: Content) -> some View {
        content
            .environment(\.keyboardShowing, isKeyboardShowing)
            .onReceive(keyboardPublisher) { isKeyboardShowing = $0 }
    }
}

extension View {
    @MainActor func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func addKeyboardToEnvironment() -> some View {
        self
            .modifier(KeyboardListenerModifier())
    }
}


extension View {
    func applyAppBackground(proxy geo: GeometryProxy, isShown: Bool = true) -> some View {
        self.background {
            Image("logo-background")
                .resizable()
                .scaledToFill()
                .frame(width: geo.size.width + geo.safeAreaInsets.leading + geo.safeAreaInsets.trailing)
                .ignoresSafeArea(.all)
                .opacity(isShown ? 0.05 : 0.0)
        }
    }
}

extension View {
    func keepScreenAlive() -> some View {
        self
            .onAppear { UIApplication.shared.isIdleTimerDisabled = true }
            .onDisappear { UIApplication.shared.isIdleTimerDisabled = false }
    }
}
