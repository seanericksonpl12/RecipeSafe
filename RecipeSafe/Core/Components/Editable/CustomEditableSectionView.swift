//
//  CustomEditableSectionView.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 12/28/24.
//

import SwiftUI

struct CustomEditableSectionView<Content: View, Item: Any>: View {
    // MARK: - Wrapped
    @Binding var list: [Item]
    @Binding var isEditing: Bool
    
    // MARK: - Properties
    var headerText: String
    var numbered: Bool
    var font: Font
    var deleteAction: (IndexSet) -> Void
    var addAction: () -> Void
    var optionalDisplay: String
   
    var content: (Int, Binding<Item>) -> Content
    
    init(
        list: Binding<[Item]>,
        isEditing: Binding<Bool>,
        headerText: String,
        numbered: Bool = false,
        font: Font = .callout,
        deleteAction: @escaping (IndexSet) -> Void,
        addAction: @escaping () -> Void,
        optionalDisplay: String = "",
        @ViewBuilder _ content: @escaping (Int, Binding<Item>) -> Content
    ) {
        self._list = list
        self._isEditing = isEditing
        self.headerText = headerText
        self.numbered = numbered
        self.font = font
        self.deleteAction = deleteAction
        self.addAction = addAction
        self.optionalDisplay = optionalDisplay
        self.content = content
    }
    
    // MARK: - Body
    var body: some View {
        Section {
            if list.isEmpty {
                HStack {
                    Spacer()
                    Button {
                        addAction()
                    } label: {
                        Image(systemName: "plus.app")
                    }
                    Spacer()
                }
            }
            ForEach(Array($list.enumerated()), id: \.offset) { index, $item in
                content(index, $item)
            }
            .onDelete { deleteAction($0) }
            .onMove { source, destination in
                list.move(fromOffsets: source, toOffset: destination)
            }
        } header: {
            HStack {
                Text(headerText)
                if isEditing {
                    Button {
                        addAction()
                    } label: {
                        Image(systemName: "plus.app")
                            .tint(.green)
                    }
                }
            }
        }
    }
}
