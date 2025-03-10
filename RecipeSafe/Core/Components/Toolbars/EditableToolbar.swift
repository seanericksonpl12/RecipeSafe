//
//  EditableToolbar.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 7/25/23.
//

import Foundation
import SwiftUI

struct EditableToolbar: ToolbarContent {
    
    @Environment(\.toolbarActions) var actions
    @Environment(\.editMode) var editMode
    @Environment(\.services.analytics) var analytics
    
    @Binding var isEditing: Bool
    
    // MARK: - Properties
    var urlLink: URL?
    var option1Text: String?
    var option2Text: String?
    
    var body: some ToolbarContent {
        Group {
            if isEditing {
                ToolbarItem {
                    Button {
                        try? actions.save()
                    } label: {
                        Text("button.save".localized)
                    }
                }
                ToolbarItem {
                    Button("button.cancel".localized, role: .destructive) {
                        try? actions.cancel()
                    }
                }
            } else {
                ToolbarItem {
                    Menu {
                        Button("button.edit".localized) {
                            analytics.trackAction(.tappedEdit)
                            Task { @MainActor in
                                withAnimation {
                                    isEditing = true
                                }
                            }
                        }
                        if let text = option1Text {
                            Button(text) {
                                try? actions.option1()
                            }
                        }
                        if let text = option2Text {
                            Button(text) {
                                try? actions.option2()
                            }
                        }
                        if let url = urlLink {
                            Link("button.link.safari".localized, destination: url)
                        }
                        Button("button.delete".localized, role: .destructive) {
                            try? actions.delete()
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
}
