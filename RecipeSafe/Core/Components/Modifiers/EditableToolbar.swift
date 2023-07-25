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
    var urlLink: URL?
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                if isEditing {
                    ToolbarItem {
                        Button {
                            saveAction()
                        } label: {
                            Text("Save")
                        }
                    }
                    ToolbarItem {
                        Button("Cancel", role: .destructive) {
                            cancelAction()
                        }
                    }
                } else {
                    ToolbarItem {
                        Menu {
                            Button("Edit") {
                                isEditing = true
                            }
                            if let url = urlLink {
                                Link("Open in Safari", destination: url)
                            }
                            Button("Delete", role: .destructive) {
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
