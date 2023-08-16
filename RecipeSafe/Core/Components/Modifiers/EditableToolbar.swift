//
//  EditableToolbar.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 7/25/23.
//

import Foundation
import SwiftUI

struct EditableToolbar: ViewModifier {
    
    // MARK: - Wrapped
    @Binding var isEditing: Bool
    
    // MARK: - Properties
    var saveAction: () -> Void
    var cancelAction: () -> Void
    var deleteAction: () -> Void
    var alternateAction: () -> Void
    var urlLink: URL?
    var alternateText: String?
    
    // MARK: - Body
    func body(content: Content) -> some View {
        content
            .toolbar {
                if isEditing {
                    ToolbarItem {
                        Button {
                            saveAction()
                        } label: {
                            Text("button.save".localized)
                        }
                    }
                    ToolbarItem {
                        Button("button.cancel".localized, role: .destructive) {
                            cancelAction()
                        }
                    }
                } else {
                    ToolbarItem {
                        Menu {
                            Button("button.edit".localized) {
                                withAnimation {
                                    isEditing = true
                                }
                            }
                            if let text = alternateText {
                                Button(text) {
                                    alternateAction()
                                }
                            }
                            if let url = urlLink {
                                Link("button.link.safari".localized, destination: url)
                            }
                            Button("button.delete".localized, role: .destructive) {
                                deleteAction()
                            }
                        } label: {
                            Image(systemName: "ellipsis")
                        }
                    }
                }
            }
    }
}
