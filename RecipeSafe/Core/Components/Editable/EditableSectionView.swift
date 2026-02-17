//
//  EditableSectionView.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 7/25/23.
//

import SwiftUI

struct EditableSectionView: View {
  // MARK: - Wrapped
  @Binding var list: [IdentifiedString]
  let isEditing: Bool
  
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
      ForEach(Array(list.enumerated()), id: \.element.id) { index, item in
        HStack {
          if numbered {
            VStack {
              Text((index + 1).formatted())
                .font(.caption)
                .fontWeight(.bold)
              Spacer()
            }
          }
          if isEditing {
            TextField(item.value.isEmpty ? optionalDisplay : "", text: $list[index].value, axis: .horizontal)
              .onSubmit {
                if !item.value.trimmingWhitespace().isEmpty {
                  addAction()
                  Task { focusState = true }
                } else {
                  list.remove(at: index)
                }
              }
              .focused($focusState, equals: index == list.count - 1 && item.value.isEmpty)
              .font(font)
          } else {
            Text(item.value)
              .font(font)
          }
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
