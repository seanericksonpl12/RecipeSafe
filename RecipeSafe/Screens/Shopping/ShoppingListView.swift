//
//  ShoppingListView.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 10/2/24.
//

import SwiftUI

extension ReferenceWritableKeyPath: @unchecked @retroactive Sendable {}

struct ShoppingListView: View {
    
    @FetchRequest(
        sortDescriptors: [SortDescriptor(\.index)],
        animation: .easeIn) private var shoppingList: FetchedResults<ShoppingListItem>
    @FetchRequest(
        sortDescriptors: [SortDescriptor(\.title)],
        animation: .easeIn) private var recipes: FetchedResults<RecipeItem>
    
    @FocusState var focused
    
    @Service var dataManager: DataManager!
    
    @State var isEditing: Bool = false

    @State private var showRecipes: Bool = true
    @State private var addRecipes: Bool = false
    @State private var addNewIngredient: Bool = false
    @State private var recipesToAdd: [RecipeItem] = []
    @State private var filteredRecipes: [RecipeItem] = []
    @State private var ingredients: [IngredientGroup] = []
    @State private var text: String = ""
    @State private var showClearAlert = false
    
    var body: some View {
        NavigationStack {
            contentView
            .navigationTitle("Grocery List")
            .environment(\.editMode, .constant(isEditing ? EditMode.active : EditMode.inactive))
            .toolbar { toolbar }
            .sheet(isPresented: $addRecipes) {
                AddRecipePopover(
                    selectedRecipes: $recipesToAdd,
                    saveAction: saveAddedRecipes,
                    recipes: Array(recipes.filter({ !filteredRecipes.contains($0) }))
                )
            }
            .alert(isPresented: $showClearAlert) {
                Alert(
                    title: Text("Are you sure you want to clear all recipes and ingredients?"),
                    primaryButton: .destructive(Text("Clear")) {
                        clearAction()
                    },
                    secondaryButton: .cancel()
                )
            }
            .task {
                refreshRecipes()
            }
        }
    }
    
    @ToolbarContentBuilder
    var toolbar: some ToolbarContent {
        if isEditing {
            ToolbarItem {
                Button {
                    saveChanges()
                } label: {
                    Text("button.save".localized)
                }
            }
            ToolbarItem {
                Button("button.cancel".localized, role: .destructive) {
                    cancelChanges()
                }
            }
        } else {
            ToolbarItem {
                Menu {
                    Button("button.edit".localized) {
                        Task { @MainActor in
                            withAnimation { isEditing = true }
                        }
                    }
                    Button("Reset Selected") {
                        resetSelected()
                    }
                    Button("Clear", role: .destructive) {
                        clear()
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .frame(width: 40, height: 40)
                        .contentShape(Rectangle())
                }
                
            }
        }
    }
    
    
    var contentView: some View {
        GeometryReader { proxy in
            VStack {
                List {
                    if showRecipes {
                        CustomEditableSectionView(
                            list: $filteredRecipes,
                            isEditing: $isEditing,
                            headerText: "Recipes",
                            deleteAction: { deleteRecipe($0) },
                            addAction: { addRecipes = true }
                        ) {
                            customRecipeItem($0, $1)
                        }
                        .moveDisabled(true)
                        .listRowBackground(Color(uiColor: UIColor.secondarySystemBackground))
                    }
                    
                    Section {
                        ForEach(Array($ingredients.enumerated()), id: \.offset) {
                            customIngredientItem($0, $1)
                        }
                        .onDelete { deleteIngredient($0) }
                        .moveDisabled(true)
                        if addNewIngredient {
                            CustomTextField(
                                text: $text,
                                prompt: "New Ingredient",
                                promptAlign: .leading,
                                staticLabel: "",
                                font: .callout,
                                fontWeight: .light,
                                axis: .vertical
                            ) {
                                self.focused = false
                                if !self.text.removingWhitespace().isEmpty {
                                    dataManager.addShoppingListItem($0, index: Int16(shoppingList.count))
                                    refreshRecipes()
                                }
                                withAnimation { addNewIngredient = false }
                                self.text = ""
                            }
                            .disabled(!addNewIngredient)
                            .focused($focused)
                        }
                    } header: {
                        HStack {
                            Text("Ingredients")
                            if isEditing {
                                Button {
                                    
                                } label: {
                                    Image(systemName: "plus.app")
                                        .tint(.green)
                                }
                            }
                        }
                    }
                    .listRowBackground(Color(uiColor: UIColor.secondarySystemBackground))
                    
                    
                }
                .scrollContentBackground(.hidden)
                
                HStack {
                    Button {
                        withAnimation { self.addNewIngredient = true }
                        self.focused = true
                    } label: {
                        Label("New Ingredient", systemImage: "plus.circle")
                    }
                    Spacer()
                }
                .padding()
            }
            .applyAppBackground(proxy: proxy)
        }
    }
    
    
    func customIngredientItem(_ index: Int, _ item: Binding<IngredientGroup>) -> some View {
        HStack {
            Button {
                withAnimation(.linear(duration: 0.1)) {
                    if index < ingredients.count {
                        ingredients[index].selected.toggle()
                    }
                    if index < shoppingList.count {
                        shoppingList[index].selected.toggle()
                        dataManager.save()
                    }
                }
            } label: {
                Image(systemName: item.wrappedValue.selected ? "checkmark.circle.fill" : "circle")
            }
            
            CustomTextField(
                text: item.text,
                prompt: "Ingredient",
                promptAlign: .leading,
                staticLabel: "",
                font: .callout,
                fontWeight: .light,
                axis: .vertical
            )
            .disabled(!isEditing)
        }
    }
    
    @ViewBuilder
    func customRecipeItem(_ index: Int, _ item: Binding<RecipeItem>) -> some View {
        if let recipe = Recipe(dataItem: item.wrappedValue) {
            NavigationLink(recipe.title) {
                RecipeView(viewModel: RecipeViewModel(recipe: recipe, screen: .allRecipes))
            }
        }
    }
}

extension ShoppingListView {
    
    func save() {
        withAnimation {
            isEditing = false
        }
    }
    
    func deleteRecipe(_ indexSet: IndexSet) {
        for index in indexSet {
            guard self.filteredRecipes.count > index else { continue }
            let recipe = self.filteredRecipes.remove(at: index)
            dataManager.removeFromShoppingList(recipe: recipe)
        }
        refreshRecipes()
    }
    
    func deleteIngredient(_ indexSet: IndexSet) {
        let list = Array(shoppingList)
        for index in indexSet {
            guard let item = list.safeValue(at: index) else { continue }
            dataManager.removeFromShoppingList(shoppingListItem: item)
        }
        refreshRecipes()
    }

    func saveAddedRecipes() {
        for recipe in recipesToAdd {
            guard !dataManager.isInShoppingList(recipe) else { continue }
            dataManager.addToShoppingList(recipe: recipe)
        }
        refreshRecipes()
        addRecipes = false
        recipesToAdd = []
    }
    
    func refreshRecipes() {
        var set = Set<RecipeItem>()
        shoppingList.forEach {
            if let recipe = $0.recipe { set.insert(recipe) }
        }
        self.filteredRecipes = Array(set)
        self.ingredients = shoppingList
            .map { IngredientGroup(shoppingListItem: $0) }
    }
    
    func saveChanges() {
        for item in ingredients {
            item.shoppingListItem.value = item.text
        }
        dataManager.save()
        withAnimation { isEditing = false }
    }
    
    func cancelChanges() {
        for i in 0..<ingredients.count {
            if let text = ingredients[i].shoppingListItem.value {
                ingredients[i].text = text
            }
        }
        Task { @MainActor in
            withAnimation { isEditing = false }
        }
    }
    
    func resetSelected() {
        withAnimation {
            for i in 0..<ingredients.count {
                ingredients[i].selected = false
            }
        }
        dataManager.save()
    }
    
    func clear() {
        self.showClearAlert = true
    }
    
    func clearAction() {
        deleteRecipe(IndexSet(0..<filteredRecipes.count))
        deleteIngredient(IndexSet(0..<ingredients.count))
    }
}

#Preview {
    ShoppingListView()
}
