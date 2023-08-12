//
//  NewGroupPopover.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 8/11/23.
//

import SwiftUI

struct NewGroupPopover: View {
    
    // MARK: - Binding
    @Binding var titleText: String
    @Binding var selectedRecipes: [RecipeItem]
    
    // MARK: - Properties
    var recipes: [RecipeItem]
    
    // MARK: - Body
    var body: some View {
        VStack {
            HStack {
                Spacer()
                TextField("", text: $titleText, prompt: Text("Title"))
                    .font(.title)
                    .fontWeight(.heavy)
                    .padding(.leading)
                Spacer()
            }
            List {
                Section {
                    ForEach(recipes) { recipe in
                        HStack {
                            Text(recipe.title ?? "")
                            Spacer()
                            Image(systemName: selectedRecipes.contains(recipe) ? "checkmark.circle.fill" : "circle")
                                .padding(.trailing)
                        }
                        .onTapGesture {
                            if selectedRecipes.contains(recipe) {
                                selectedRecipes.removeAll(where: {$0 == recipe})
                            } else {
                                selectedRecipes.append(recipe)
                            }
                        }
                    }
                } header : {
                    Text("Add Recipes: ")
                }
                
            }
        }
    }
}
