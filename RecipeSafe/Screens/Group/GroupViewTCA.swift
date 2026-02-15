import ComposableArchitecture
import SwiftUI

struct GroupViewTCA: View {
  
  @Bindable var store: StoreOf<GroupReducer>
  
  init(store: StoreOf<GroupReducer>) {
    self.store = store
  }
  
  var body: some View {
    NavigationStack(path: $store.scope(state: \.navPath, action: \.navPath)) {
      VStack {
        // MARK: - Header
        GroupHeaderImage(group: $store.group)
          .frame(maxHeight: 40)
          .editableToolbar(
            isEditing: $store.editingEnabled,
            save: { store.send(.saveChanges) },
            delete: { store.send(.deleteGroup) },
            cancel: { store.send(.cancelChanges) }
          )
        
        // MARK: - Recipes
        TabbedList(
          textFieldTitle: Binding(
            get: { store.group.title },
            set: { store.send(.titleChanged($0)) }
          ),
          editing: $store.editingEnabled,
          textFieldPrompt: "group.title.prompt".localized
        ) {
          ForEach(store.group.recipes) { recipe in
            Button {
              store.send(.recipeTapped(recipe))
            } label: {
              Text(recipe.title)
            }
          }
          .onDelete { store.send(.removeRecipe($0)) }
          .onMove { store.send(.moveRecipes(from: $0, to: $1)) }
          
          if !store.availableRecipes.isEmpty {
            Section {
              HStack {
                Spacer()
                Button {
                  store.send(.addRecipe)
                } label: {
                  Image(systemName: "plus.circle")
                    .foregroundColor(.primary)
                }
                Spacer()
              }
            } header: {
              Text("group.list.add".localized + store.group.title)
            }
          } else if store.group.recipes.isEmpty {
            EmptyGroupView()
          }
        }
        .environment(\.editMode, .constant(store.editingEnabled ? EditMode.active : EditMode.inactive))
        .navigationBarTitleDisplayMode(.inline)
      }
      .alert($store.scope(state: \.alert, action: \.alert))
      .popover(item: $store.scope(state: \.destination?.addRecipe, action: \.destination.addRecipe)) { store in
        AddRecipeViewTCA(store: store)
      }
    } destination: { (path: StoreOf<GroupReducer.NavPath>) in
      switch path.case {
      case let .recipe(store):
        RecipeView(store: store)
      }
    }
    .task {
      store.send(.task)
    }
    .pageLoad(.group)
  }
}

struct AddRecipeViewTCA: View {
  @Bindable var store: StoreOf<AddRecipeReducer>
  
  var body: some View {
    NavigationStack {
      List {
        ForEach(store.searchList) { recipe in
          HStack {
            Text(recipe.title)
            Spacer()
            Image(systemName: store.selectedRecipes.contains(recipe) ? "checkmark.circle.fill" : "circle")
          }
          .onTapGesture {
            store.send(.recipeTapped(recipe))
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
            store.send(.save)
          }
          .padding()
        }
      }
      .searchable(
        text: Binding(
          get: { store.searchText },
          set: { store.send(.binding(.set(\.searchText, $0))) }
        ),
        prompt: Text("tool.search".localized)
      )
    }
  }
}

