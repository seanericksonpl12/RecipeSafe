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
                         url: URL?,
                         saveAction: @escaping () -> Void,
                         cancelAction: @escaping () -> Void,
                         deleteAction: @escaping () -> Void) -> some View {
        
        modifier(EditableToolbar(isEditing: isEditing,
                                 saveAction: saveAction,
                                 cancelAction: cancelAction,
                                 deleteAction: deleteAction,
                                 urlLink: url))
    }
}
