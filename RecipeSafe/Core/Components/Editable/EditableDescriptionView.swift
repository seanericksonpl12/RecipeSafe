//
//  EditableDescriptionView.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 7/25/23.
//

import SwiftUI

struct EditableDescriptionView: View {
    
    @Binding var isEditing: Bool
    @Binding var description: String
    @Binding var prepTime: String
    @Binding var cookTime: String
    
    var optionalDisplay: String?
    
    var body: some View {
        Section {
            VStack {
                if !description.isEmpty || isEditing {
                    CustomTextField(text: $description,
                                    prompt: optionalDisplay ?? "",
                                    promptAlign: .center,
                                    staticLabel: nil,
                                    font: .callout,
                                    fontWeight: .light,
                                    axis: .vertical)
                    .disabled(!isEditing)
                }
                HStack {
                    Spacer()
                    if !prepTime.isEmpty || isEditing {
                        CustomTextField(text: $prepTime,
                                        prompt: "recipe.preptime.label".localized,
                                        promptAlign: .leading,
                                        staticLabel: "recipe.preptime".localized,
                                        font: .footnote,
                                        fontWeight: .light,
                                        axis: .horizontal)
                        .disabled(!isEditing)
                    }
                    Spacer()
                    if !cookTime.isEmpty || isEditing {
                        CustomTextField(text: $cookTime,
                                        prompt: "recipe.preptime.label".localized,
                                        promptAlign: .leading,
                                        staticLabel: "recipe.cooktime".localized,
                                        font: .footnote,
                                        fontWeight: .light,
                                        axis: .horizontal)
                        .disabled(!isEditing)
                    }
                    Spacer()
                }
            }
        }
    }
}
