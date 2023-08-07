//
//  CustomTextField.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 8/7/23.
//

import SwiftUI

struct CustomTextField: View {
    
    @Binding var text: String
    @FocusState private var focused: Bool
    let prompt: String
    
    var body: some View {
        ZStack {
            
            if text.isEmpty && !focused {
                Text(prompt)
                    .opacity(0.5)
                    .font(.callout)
                    .fontWeight(.light)
            }
            
            TextField("", text: $text, axis: .vertical)
                .multilineTextAlignment(.center)
                .font(.callout)
                .fontWeight(.light)
                .focused($focused)
        }
    }
}
