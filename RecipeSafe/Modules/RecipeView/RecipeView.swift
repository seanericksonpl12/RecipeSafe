//
//  RecipeView.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 7/17/23.
//

import SwiftUI

struct RecipeView: View {
    
    @State var recipe: Recipe = Recipe(title: "", ingredients: [])
    
    // MARK: - Body
    var body: some View {
        
        customHeader
        
        List {
            
            Section {
                customDescriptionSection
            }
            
            Section {
                ForEach(recipe.ingredients, id: \.self) { item in
                    Text(item)
                        .font(.callout)
                }
            } header: {
                Text("Ingredients")
            }
            
            Section {
                ForEach(Array(recipe.instructions.enumerated()), id: \.offset) { index, item in
                    HStack {
                        VStack {
                            Text((index + 1).formatted())
                                .font(.caption)
                                .fontWeight(.bold)
                            Spacer()
                        }
                        Text(item)
                            .font(.callout)
                    }
                }
            } header: {
                Text("Instructions")
            }
        }
        
    }
    
    // MARK: - Header
    var customHeader: some View {
        HStack {
            Spacer()
            AsyncImage(url: recipe.img) { img in
                img.resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: 70, maxHeight: 70)
                    .clipShape(Circle())
            } placeholder: {
                Image(systemName: "circle.dotted")
                    .frame(maxWidth: 70, maxHeight: 70)
            }
            
            Text(recipe.title)
                .font(.title)
                .padding()
            Spacer()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    print("Open Menu")
                } label: {
                    Image(systemName: "ellipsis")
                }
            }
        }
    }
    
    // MARK: - Description
    var customDescriptionSection: some View {
        VStack {
            Text(recipe.description ?? "")
                .multilineTextAlignment(.center)
                .font(.callout)
                .fontWeight(.light)
            Divider()
            HStack {
                Spacer()
                if let prep = recipe.prepTime {
                    Text("Prep Time: \(prep)")
                        .font(.footnote)
                }
                Spacer()
                if let cook = recipe.cookTime {
                    Text("Cook Time: \(cook)")
                        .font(.footnote)
                }
                Spacer()
            }
        }
    }
    
}

struct RecipeView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeView(recipe: Recipe(title: "Shrimp Tacos", ingredients: ["Shrimp tails", "Cajon Seasoning", "Oil"]))
    }
}
