//
//  AddItemChip.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 3/9/26.
//

import SwiftUI

struct AddItemChipButton: View {
  let label: String
  let action: () -> Void

  var body: some View {
    Button {
      action()
    } label: {
      HStack(spacing: 4) {
        Image(systemName: "plus")
          .font(.caption.weight(.semibold))
        Text(label)
          .font(.subheadline)
          .fontWeight(.medium)
      }
      .foregroundStyle(.blue)
      .padding(.horizontal, 14)
      .frame(minHeight: 44)
      .background(Color.blue.opacity(0.06), in: RoundedRectangle(cornerRadius: 12))
      .overlay(
        RoundedRectangle(cornerRadius: 12)
          .strokeBorder(Color.blue.opacity(0.25), style: StrokeStyle(lineWidth: 1.5, dash: [5, 4]))
      )
    }
    .buttonStyle(.plain)
  }
}
