//
//  AddRecipePopover.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 8/11/23.
//

import SwiftUI

struct AddRecipePopover: View {
    
    // MARK: - Wrappers
    @State private var searchText: String = ""
    @Binding var selectedRecipes: [RecipeItem]
    
    // MARK: - Properties
    var saveAction: () -> Void
    var recipes: [RecipeItem]
    
    // MARK: - Computed
    var searchList: [RecipeItem] {
        if searchText.isEmpty { return recipes }
        else { return recipes.filter({ $0.title?.lowercased().contains(searchText.lowercased()) ?? false })}
    }
    
    // MARK: - Body
    var body: some View {
        
        NavigationStack {
            List {
                ForEach(searchList) { recipe in
                    HStack {
                        Text(recipe.title ?? "")
                        Spacer()
                        Image(systemName: selectedRecipes.contains(recipe) ? "checkmark.circle.fill" : "circle")
                    }
                    .onTapGesture {
                        if selectedRecipes.contains(recipe) {
                            selectedRecipes.removeAll(where: {$0 == recipe})
                        } else {
                            selectedRecipes.append(recipe)
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("group.recipes.add".localized)
                        .font(.title)
                        .fontWeight(.heavy)
                        .padding()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("button.save".localized) {
                        saveAction()
                    }
                    .padding()
                }
            }
            
        }
        .searchable(text: $searchText, prompt: Text("tool.search".localized))
        
    }
}
