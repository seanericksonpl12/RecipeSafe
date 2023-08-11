//
//  EditableToolbar.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 7/25/23.
//

import Foundation
import SwiftUI

struct EditableToolbar: ViewModifier {
    
    @Binding var isEditing: Bool
    
    var saveAction: () -> Void
    var cancelAction: () -> Void
    var deleteAction: () -> Void
    var groupAction: () -> Void
    var urlLink: URL?
    
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
                            Button("Add to Group") {
                                groupAction()
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
