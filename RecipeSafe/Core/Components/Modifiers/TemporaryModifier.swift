//
//  Temporary.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 2/7/25.
//

import SwiftUI

struct TemporaryModifier<Overlay: View>: ViewModifier {
    
    @ViewBuilder let overlay: () -> Overlay
    let duration: TimeInterval
    @State private var isVisible = false
    @Binding var trigger: Bool
    
    @ViewBuilder
    var overlayBody: some View {
        if isVisible {
            overlay()
                .transition(.opacity)
        }
    }
    
    func body(content: Content) -> some View {
        content
            .overlay(
                overlayBody
            )
            .onChange(of: trigger) {
                if trigger {
                    triggerAnimation()
                }
            }
    }
    
    func triggerAnimation() {
        withAnimation(.easeIn(duration: 0.3)) {
            isVisible = true
        }
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: UInt64(duration) * 1_000_000_000)
            withAnimation(.easeOut(duration: 0.3)) {
                isVisible = false
                self.trigger = false
            }
        }
    }
}

