//
//  EditableSectionView.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 7/25/23.
//

import SwiftUI

struct EditableSectionView: View {
    // MARK: - Wrapped
    @Binding var list: [String]
    @Binding var isEditing: Bool
    
    @FocusState var focusState
    
    // MARK: - Properties
    var headerText: String
    var numbered: Bool = false
    var font: Font = .callout
    var deleteAction: (IndexSet) -> Void
    var addAction: () -> Void
    var optionalDisplay: String = ""
    
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
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
            }
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
                    TextField(item == "" ? optionalDisplay : "", text: $list[index], axis: isEditing ? .horizontal : .vertical)
                        .onSubmit {
                            if !item.trimmingWhitespace().isEmpty {
                                addAction()
                                Task { focusState = true }
                            } else {
                                list.remove(at: index)
                            }
                        }
                        .focused($focusState, equals: index == list.count - 1 && item.isEmpty)
                        .font(font)
                        .disabled(!isEditing)
                }
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
