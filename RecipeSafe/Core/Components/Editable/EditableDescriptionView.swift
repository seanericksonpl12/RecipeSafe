//
//  EditableDescriptionView.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 7/25/23.
//

import SwiftUI

struct EditableDescriptionView< T: EditableRecipeModel>: View {
    
    @EnvironmentObject var viewModel: T
    
    var optionalDisplay: String?
    
    // MARK: - Body
    var body: some View {
        Section {
            VStack {
                if !viewModel.descriptionText.isEmpty || viewModel.editingEnabled {
                    CustomTextField(text: $viewModel.descriptionText,
                                    prompt: optionalDisplay ?? "",
                                    promptAlign: .center,
                                    staticLabel: nil,
                                    font: .callout,
                                    fontWeight: .light,
                                    axis: .vertical)
                    .disabled(!viewModel.editingEnabled)
                }
                HStack {
                    Spacer()
                    if !viewModel.prepText.isEmpty || viewModel.editingEnabled {
                        CustomTextField(text: $viewModel.prepText,
                                        prompt: "recipe.preptime.label".localized,
                                        promptAlign: .leading,
                                        staticLabel: "recipe.preptime".localized,
                                        font: .footnote,
                                        fontWeight: .light,
                                        axis: .horizontal)
                        .disabled(!viewModel.editingEnabled)
                    }
                    Spacer()
                    if !viewModel.cookText.isEmpty || viewModel.editingEnabled {
                        CustomTextField(text: $viewModel.cookText,
                                        prompt: "recipe.preptime.label".localized,
                                        promptAlign: .leading,
                                        staticLabel: "recipe.cooktime".localized,
                                        font: .footnote,
                                        fontWeight: .light,
                                        axis: .horizontal)
                        .disabled(!viewModel.editingEnabled)
                    }
                    Spacer()
                }
            }
        }
    }
}
