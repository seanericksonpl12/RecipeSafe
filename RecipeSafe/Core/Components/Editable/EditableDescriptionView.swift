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
    
    var prepTime: String?
    var cookTime: String?
    var optionalDisplay: String?
    
    var body: some View {
        Section {
            VStack {
                CustomTextField(text: $description, prompt: optionalDisplay ?? "")
                    .disabled(!isEditing)
                
                HStack {
                    Spacer()
                    if let prep = prepTime {
                        Text("recipe.preptime".localized + prep)
                            .font(.footnote)
                    }
                    Spacer()
                    if let cook = cookTime {
                        Text("recipe.cooktime".localized + cook)
                            .font(.footnote)
                    }
                    Spacer()
                }
            }
        }
    }
}
