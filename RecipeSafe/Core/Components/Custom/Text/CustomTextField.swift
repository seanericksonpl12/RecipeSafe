//
//  CustomTextField.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 8/7/23.
//

import SwiftUI

struct CustomTextField: View {
    
    // MARK: - Wrapped
    @Binding var text: String
    @FocusState private var focused: Bool
    
    // MARK: - Properties
    let prompt: String
    let promptAlign: Alignment
    let staticLabel: String?
    let font: Font
    let fontWeight: Font.Weight
    let axis: Axis
    let lineLimit: Int?
    var onSubmitAction: (String) -> Void = { _ in }
    
    // MARK: - Body
    var body: some View {
        HStack {
            if let text = staticLabel {
                Text(text)
                    .font(font)
                    .fontWeight(fontWeight)
                    .padding(.trailing, 0)
            }
            ZStack {
                
                if text.isEmpty && !focused {
                    Text(prompt)
                        .frame(maxWidth: .infinity, alignment: promptAlign)
                        .opacity(0.5)
                        .font(font)
                        .fontWeight(fontWeight)
                }
                
                TextField("", text: $text, axis: axis)
                    .lineLimit(lineLimit)
                    .multilineTextAlignment(staticLabel == nil ? .center : .leading)
                    .font(font)
                    .fontWeight(fontWeight)
                    .focused($focused)
                    .onSubmit {
                        self.focused = false
                        onSubmitAction(text)
                    }
            }
        }
    }
    
    func onSubmitAction(_ action: @escaping (String) -> Void) -> Self {
        var copy = self
        copy.onSubmitAction = action
        return copy
    }
}
