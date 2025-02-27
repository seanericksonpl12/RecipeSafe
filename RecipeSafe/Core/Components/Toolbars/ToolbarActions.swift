//
//  ToolbarService.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 2/19/25.
//

import SwiftUI

struct ToolbarActions: Sendable, Injectable {
    static var defaultValue: Self { .init() }
    
    var save: @MainActor @Sendable () throws -> Void
    var delete: @MainActor @Sendable () throws -> Void
    var cancel: @MainActor @Sendable () throws -> Void
    var option1: @MainActor @Sendable () throws -> Void
    var option2: @MainActor @Sendable () throws -> Void
    
    init(
        save: @escaping @Sendable @MainActor () throws -> Void = {},
        delete: @escaping @Sendable @MainActor () throws -> Void = {},
        cancel: @escaping @Sendable @MainActor () throws -> Void = {},
        option1: @escaping @Sendable @MainActor () throws -> Void = {},
        option2: @escaping @Sendable @MainActor () throws -> Void = {}
    ) {
        self.save = save
        self.delete = delete
        self.cancel = cancel
        self.option1 = option1
        self.option2 = option2
    }
}

struct ToolbarActionsModifier: ViewModifier {
    
    @Binding var isEditing: Bool
    
    let urlLink: URL?
    let option1Text: String?
    let option2Text: String?
    let actions: ToolbarActions?
    
    func body(content: Content) -> some View {
        if let actions {
            content
                .toolbar { EditableToolbar(isEditing: $isEditing, urlLink: urlLink, option1Text: option1Text, option2Text: option2Text) }
                .environment(\.toolbarActions, actions)
        } else {
            content
                .toolbar { EditableToolbar(isEditing: $isEditing, urlLink: urlLink, option1Text: option1Text, option2Text: option2Text) }
        }
    }
}

extension View {
    
    func editableToolbar(
        isEditing: Binding<Bool>,
        urlLink: URL? = nil,
        option1Text: String? = nil,
        option2Text: String? = nil
    ) -> some View {
        self.modifier(
            ToolbarActionsModifier(
                isEditing: isEditing,
                urlLink: urlLink,
                option1Text: option1Text,
                option2Text: option2Text,
                actions: nil
            )
        )
    }
    
    func editableToolbar(
        isEditing: Binding<Bool>,
        urlLink: URL? = nil,
        option1Text: String? = nil,
        option2Text: String? = nil,
        actions: ToolbarActions
    ) -> some View {
        self.modifier(
            ToolbarActionsModifier(
                isEditing: isEditing,
                urlLink: urlLink,
                option1Text: option1Text,
                option2Text: option2Text,
                actions: actions
            )
        )
    }
    
    func editableToolbar(
        isEditing: Binding<Bool>,
        urlLink: URL? = nil,
        option1Text: String? = nil,
        option2Text: String? = nil,
        save: (@MainActor @Sendable () throws -> Void)? = nil,
        delete: (@MainActor @Sendable () throws -> Void)? = nil,
        cancel: (@MainActor @Sendable () throws -> Void)? = nil,
        option1: (@MainActor @Sendable () throws -> Void)? = nil,
        option2: (@MainActor @Sendable () throws -> Void)? = nil
    ) -> some View {
        
        let newActions = ToolbarActions(
            save: save ?? {},
            delete: delete ?? {},
            cancel: cancel ?? {},
            option1: option1 ?? {},
            option2: option2 ?? {}
        )
        
        return self.modifier(
            ToolbarActionsModifier(
                isEditing: isEditing,
                urlLink: urlLink,
                option1Text: option1Text,
                option2Text: option2Text,
                actions: newActions
            )
        )
    }
}
