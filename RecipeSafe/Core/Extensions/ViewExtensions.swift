//
//  ViewExtensions.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 7/25/23.
//

import Foundation
import SwiftUI

extension View {
    func editableToolbar(isEditing: Binding<Bool>,
                         url: URL? = nil,
                         alternateLabel: String? = nil,
                         saveAction: @escaping () -> Void = {},
                         cancelAction: @escaping () -> Void = {},
                         deleteAction: @escaping () -> Void = {},
                         alternateAction: @escaping () -> Void = {}) -> some View {
        
        modifier(EditableToolbar(isEditing: isEditing,
                                 saveAction: saveAction,
                                 cancelAction: cancelAction,
                                 deleteAction: deleteAction,
                                 alternateAction: alternateAction,
                                 urlLink: url,
                                 alternateText: alternateLabel))
    }
}

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
