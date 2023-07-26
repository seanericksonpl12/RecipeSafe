//
//  EditableSectionView.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 7/25/23.
//

import SwiftUI

struct EditableSectionView: View {
    @Binding var list: [String]
    @Binding var isEditing: Bool
    
    var headerText: String
    var numbered: Bool = false
    var font: Font = .callout
    var deleteAction: (IndexSet) -> Void
    var addAction: () -> Void
    var optionalDisplayValue: String = ""
    
    var body: some View {
        Section {
            ForEach(Array(list.enumerated()), id: \.offset) { index, item in
                HStack {
                    if numbered {
                        VStack {
                            Text((index + 1).formatted())
                                .font(.caption)
                                .fontWeight(.bold)
                            Spacer()
                        }
                    }
                    TextField(item == "" ? optionalDisplayValue : "", text: $list[index], axis: .vertical)
                        .font(font)
                        .disabled(!isEditing)
                }
            }
            .onDelete { deleteAction($0) }
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