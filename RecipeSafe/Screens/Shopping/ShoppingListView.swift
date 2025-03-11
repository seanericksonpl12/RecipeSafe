//
//  ShoppingListView.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 10/2/24.
//

import SwiftUI
import CoreData

extension ReferenceWritableKeyPath: @unchecked @retroactive Sendable {}

struct ShoppingListView: View {
    
    @FetchRequest(
        sortDescriptors: [SortDescriptor(\.index)],
        animation: .easeIn) private var shoppingList: FetchedResults<ShoppingListItem>
    @FetchRequest(
        sortDescriptors: [SortDescriptor(\.title)],
        animation: .easeIn) private var recipes: FetchedResults<RecipeItem>
    
    @Environment(\.services.shoppingListData) var dataService
    @Environment(\.keyboardShowing) var isKeyboardShowing
    
    @FocusState var focused
    @FocusState var itemFocus: ShoppingListItem?
    
    @State var isEditing: Bool = false
    @State private var showRecipes: Bool = true
    @State private var addRecipes: Bool = false
    @State private var recipesToAdd: [RecipeItem] = []
    @State private var filteredRecipes: [RecipeItem] = []
    @State private var tempIngredients: [NSManagedObjectID : (String?, Int16)] = [:]
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
                            deleteRecipe(IndexSet(0..<filteredRecipes.count))
                            deleteIngredient(IndexSet(0..<shoppingList.count))
                        },
                        secondaryButton: .cancel()
                    )
                }
                .onChange(of: isEditing) { _, value in
                    if value {
                        for item in shoppingList {
                            self.tempIngredients[item.objectID] = (item.value, item.index)
                        }
                    } else {
                        self.tempIngredients = [:]
                    }
                }
            
                .pageLoad(.shoppingList)
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
                        self.showClearAlert = true
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
        ScrollViewReader { scrollProxy in
            VStack {
                List {
                    if showRecipes {
                        CustomEditableSectionView(
                            list: recipes.filter { dataService.isInList($0) },
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
                    
                    if shoppingList.isEmpty {
                        HStack {
                            Spacer()
                            EmptyListView(description: "Add some ingredients or a new recipe to get started!")
                                .listRowBackground(Color(uiColor: .clear))
                            Spacer()
                        }
                    }
                    
                    Section {
                        
                        ForEach(shoppingList) { item in
                            HStack {
                                Button {
                                    withAnimation(.linear(duration: 0.1)) {
                                        item.selected.toggle()
                                        try? dataService.saveContext()
                                    }
                                } label: {
                                    Image(systemName: item.selected ? "checkmark.circle.fill" : "circle")
                                }
                                .disabled(isKeyboardShowing)
                                
                                CustomTextField(
                                    text: .init(get: { item.value ?? "" }, set: { item.value = $0; if $0.contains("\n") {
                                        withAnimation {
                                            scrollProxy.scrollTo(999, anchor: .bottom)
                                        }
                                        submit(item: item)
                                    } }),
                                    prompt: "Ingredient",
                                    promptAlign: .leading,
                                    staticLabel: "",
                                    font: .callout,
                                    fontWeight: .light,
                                    axis: .vertical,
                                    lineLimit: 1
                                ) { _ in
                                    withAnimation {
                                        scrollProxy.scrollTo(999, anchor: .bottom)
                                    }
                                    submit(item: item)
                                }
                                .focused($itemFocus, equals: item)
                                .disabled(!isEditing)
                            }
                        }
                        .onDelete { deleteIngredient($0) }
                        .moveDisabled(true)
                    } header: {
                        if !shoppingList.isEmpty {
                            HStack {
                                Text("Ingredients")
                            }
                        }
                    }
                    .listRowBackground(Color(uiColor: UIColor.secondarySystemBackground))
                    Rectangle().id(999).frame(height: 0).foregroundStyle(.clear)
                        .listRowBackground(Color(uiColor: .clear))
                }
                .scrollContentBackground(.hidden)
                
                
                if !isKeyboardShowing {
                    HStack {
                        Button {
                            scrollProxy.scrollTo(999, anchor: .bottom)
                            try? dataService.createAndAdd("", Int16(shoppingList.count))
                            Task { @MainActor in
                                itemFocus = shoppingList.last
                            }
                            
                        } label: {
                            Label("New Ingredient", systemImage: "plus.circle")
                        }
                        Spacer()
                    }
                    .padding()
                } else {
                    HStack {
                        Button {
                            try? dataService.removeItemFromList(shoppingList.last)
                            itemFocus = nil
                        } label: {
                            Text("Cancel")
                        }
                        Spacer()
                    }
                    .padding()
                }
                
            }
        }
    }
    
    @ViewBuilder
    func customRecipeItem(_ index: Int, _ item: RecipeItem) -> some View {
        if let recipe = Recipe(dataItem: item) {
            NavigationLink(recipe.title) {
                RecipeView(recipe: recipe, screen: .allRecipes)
            }
        }
    }
}

extension ShoppingListView {
    
    func submit(item: ShoppingListItem) {
        if item == shoppingList.last {
            let trimmed = item.value?.trimmingWhitespace().removingNewLines() ?? ""
            
            if trimmed.isEmpty {
                try? dataService.removeItemFromList(item)
                itemFocus = nil
            } else {
                item.value = trimmed
                try? dataService.saveContext()
                if !isEditing {
                    try? dataService.createAndAdd("", Int16(shoppingList.count))
                    Task { @MainActor in
                        itemFocus = shoppingList.last
                    }
                }
            }
        }
        
        refreshIndices()
    }
    
    func save() {
        withAnimation {
            isEditing = false
        }
    }
    
    func deleteRecipe(_ indexSet: IndexSet) {
        let recipes = recipes.filter { dataService.isInList($0) }
        for index in indexSet {
            guard recipes.count > index else { continue }
            let recipe = recipes[index]
            try? dataService.removeRecipeFromList(recipe)
        }
    }
    
    func deleteIngredient(_ indexSet: IndexSet) {
        let list = Array(shoppingList)
        for index in indexSet {
            guard let item = list.safeValue(at: index) else { continue }
            try? dataService.removeItemFromList(item)
        }
        refreshIndices()
    }
    
    func saveAddedRecipes() {
        for recipe in recipesToAdd {
            guard !dataService.isInList(recipe) else { continue }
            try? dataService.addToList(recipe)
        }
        addRecipes = false
        recipesToAdd = []
    }
    
    func refreshIndices() {
        for (index, item) in shoppingList.enumerated() {
            item.index = Int16(index)
        }
        try? dataService.saveContext()
    }
    
    func saveChanges() {
        try? dataService.saveContext()
        withAnimation { isEditing = false }
    }
    
    func cancelChanges() {
        withAnimation { isEditing = false }
        for i in 0..<shoppingList.count {
            let id = shoppingList[i].objectID
            shoppingList[i].value = tempIngredients[id]?.0
            tempIngredients[id] = nil
        }
        if tempIngredients.count > 0 {
            for (key, val) in tempIngredients {
                print(val)
                try? dataService.createAndAdd(val.0, val.1)
                tempIngredients[key] = nil
            }
        }
        try? dataService.saveContext()
    }
    
    func resetSelected() {
        withAnimation {
            for i in 0..<shoppingList.count {
                shoppingList[i].selected = false
            }
        }
        try? dataService.saveContext()
    }
}

#Preview {
    ShoppingListView()
}
