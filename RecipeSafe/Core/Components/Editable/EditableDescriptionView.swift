//
//  EditableDescriptionView.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 7/25/23.
//

import SwiftUI

struct EditableDescriptionView: View {
    
    @Binding var recipe: Recipe
    var editingEnabled: Bool
    
    var optionalDisplay: String?
    
    // MARK: - Body
    var body: some View {
        Section {
            VStack {
                if !recipe.description.isEmpty || editingEnabled {
                    CustomTextField(
                        text: $recipe.description,
                        prompt: optionalDisplay ?? "",
                        promptAlign: .center,
                        staticLabel: nil,
                        font: .callout,
                        fontWeight: .light,
                        axis: .vertical,
                        lineLimit: nil
                    )
                    .disabled(!editingEnabled)
                }
              IconImage(isEditing: false, img: recipe.img)
                HStack {
                    Spacer()
                    if !recipe.prepTime.isEmpty || editingEnabled {
                        CustomTextField(
                            text: $recipe.prepTime,
                            prompt: "recipe.preptime.label".localized,
                            promptAlign: .leading,
                            staticLabel: "recipe.preptime".localized,
                            font: .footnote,
                            fontWeight: .light,
                            axis: .horizontal,
                            lineLimit: 1
                        )
                        .disabled(!editingEnabled)
                    }
                    Spacer()
                    if !recipe.cookTime.isEmpty || editingEnabled {
                        CustomTextField(
                            text: $recipe.cookTime,
                            prompt: "recipe.preptime.label".localized,
                            promptAlign: .leading,
                            staticLabel: "recipe.cooktime".localized,
                            font: .footnote,
                            fontWeight: .light,
                            axis: .horizontal,
                            lineLimit: 1
                        )
                        .disabled(!editingEnabled)
                    }
                    Spacer()
                }
            }
        }
    }
}
