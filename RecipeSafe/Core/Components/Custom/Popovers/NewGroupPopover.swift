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
    @State var editBind: Bool = true
    
    // MARK: - Properties
    var recipes: [RecipeItem]
    var allowSelection: Bool = true
    var color: Color
    
    // MARK: - Body
    var body: some View {
        VStack {
            
            color
                .ignoresSafeArea()
                .frame(maxHeight: 40)
                .padding(.bottom, -10)
            
            TabbedList(textFieldTitle: $titleText, editing: $editBind, textFieldPrompt: "group.new.title".localized) {
                Section {
                    ForEach(recipes) { recipe in
                        HStack {
                            Text(recipe.title ?? "")
                            Spacer()
                            Image(systemName: selectedRecipes.contains(recipe) ? "checkmark.circle.fill" : "circle")
                                .padding(.trailing)
                        }
                        .onTapGesture {
                            if allowSelection {
                                if selectedRecipes.contains(recipe) {
                                    selectedRecipes.removeAll(where: {$0 == recipe})
                                } else {
                                    selectedRecipes.append(recipe)
                                }
                            }
                        }
                    }
                    if recipes.isEmpty {
                        EmptyGroupView()
                    }
                } header : {
                    Text("group.new.header".localized)
                }
                
            }
        }
    }
}
