//
//  ViewExtensions.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 7/25/23.
//

import Foundation
import SwiftUI

// MARK: - Hide Keyboard
#if canImport(UIKit)
extension View {
    @MainActor func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif

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
