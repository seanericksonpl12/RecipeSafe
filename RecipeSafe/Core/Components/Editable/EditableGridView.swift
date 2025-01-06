//
//  EditableGridView.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 12/28/24.
//

import SwiftUI

struct EditableGridView<Content: View, Item: Any>: View {
    
    @Binding var isEditing: Bool
    var list: [Item]
    @ViewBuilder var content: (Int, Item) -> Content
    
    var body: some View {
        LazyVGrid(columns:  [
            GridItem(),
            GridItem(),
            GridItem()
        ]) {
            ForEach(Array(list.enumerated()), id: \.offset) { index, item in
                content(index, item)
            }
        }
    }
}
