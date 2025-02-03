//
//  EditableToolbar.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 7/25/23.
//

import Foundation
import SwiftUI

struct EditableToolbar: ToolbarContent {
    
    @Binding var isEditing: Bool
    
    // MARK: - Properties
    var saveAction: () -> Void = {}
    var cancelAction: () -> Void = {}
    var deleteAction: () -> Void = {}
    var option1Action: () -> Void = {}
    var option2Action: () -> Void = {}
    var urlLink: URL? = nil
    var option1Text: String?
    var option2Text: String?
    
    var body: some ToolbarContent {
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
                        Task { @MainActor in
                            withAnimation {
                                isEditing = true
                            }
                        }
                    }
                    if let text = option1Text {
                        Button(text) {
                            option1Action()
                        }
                    }
                    if let text = option2Text {
                        Button(text) {
                            option2Action()
                        }
                    }
                    if let url = urlLink {
                        Link("button.link.safari".localized, destination: url)
                    }
                    Button("button.delete".localized, role: .destructive) {
                        deleteAction()
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .frame(width: 40, height: 40)
                        .contentShape(Rectangle())
                }
                
            }
        }
    }
}
