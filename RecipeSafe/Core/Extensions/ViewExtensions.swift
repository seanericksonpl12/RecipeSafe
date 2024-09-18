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
