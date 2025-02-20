//
//  EditableDescriptionView.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 7/25/23.
//

import SwiftUI

struct EditableDescriptionView: View {
    
    @Binding var descriptionText: String
    @Binding var prepText: String
    @Binding var cookText: String
    @Binding var editingEnabled: Bool
    
    var optionalDisplay: String?
    
    // MARK: - Body
    var body: some View {
        Section {
            VStack {
                if !descriptionText.isEmpty || editingEnabled {
                    CustomTextField(
                        text: $descriptionText,
                        prompt: optionalDisplay ?? "",
                        promptAlign: .center,
                        staticLabel: nil,
                        font: .callout,
                        fontWeight: .light,
                        axis: .vertical
                    )
                    .disabled(!editingEnabled)
                }
                HStack {
                    Spacer()
                    if !prepText.isEmpty || editingEnabled {
                        CustomTextField(
                            text: $prepText,
                            prompt: "recipe.preptime.label".localized,
                            promptAlign: .leading,
                            staticLabel: "recipe.preptime".localized,
                            font: .footnote,
                            fontWeight: .light,
                            axis: .horizontal
                        )
                        .disabled(!editingEnabled)
                    }
                    Spacer()
                    if !cookText.isEmpty || editingEnabled {
                        CustomTextField(
                            text: $cookText,
                            prompt: "recipe.preptime.label".localized,
                            promptAlign: .leading,
                            staticLabel: "recipe.cooktime".localized,
                            font: .footnote,
                            fontWeight: .light,
                            axis: .horizontal
                        )
                        .disabled(!editingEnabled)
                    }
                    Spacer()
                }
            }
        }
    }
}
