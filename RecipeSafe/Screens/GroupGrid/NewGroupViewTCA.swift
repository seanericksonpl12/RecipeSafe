import ComposableArchitecture
import SwiftUI

struct NewGroupViewTCA: View {
  
  @Bindable var store: StoreOf<NewGroupReducer>
  
  init(store: StoreOf<NewGroupReducer>) {
    self.store = store
  }
  
  var body: some View {
    VStack {
      ColorSet.color(store.newGroupColor)
        .ignoresSafeArea()
        .frame(maxHeight: 40)
        .padding(.bottom, -10)
      
      TabbedList(
        textFieldTitle: $store.title,
        editing: .constant(true),
        textFieldPrompt: "group.new.title".localized
      ) {
        Section {
          ForEach(store.availableRecipes) { recipe in
            HStack {
              Text(recipe.title ?? "")
              Spacer()
              Image(systemName: store.selectedRecipes.contains(recipe) ? "checkmark.circle.fill" : "circle")
                .padding(.trailing)
            }
            .onTapGesture {
              if store.selectedRecipes.contains(recipe) {
                store.selectedRecipes.removeAll(where: { $0 == recipe })
              } else {
                store.selectedRecipes.append(recipe)
              }
            }
          }
          if store.availableRecipes.isEmpty {
            EmptyGroupView()
          }
        } header: {
          Text("group.new.header".localized)
        }
      }
    }
    .editableToolbar(
      isEditing: .constant(true),
      save: { store.send(.saveGroup) },
      cancel: { store.send(.cancel) }
    )
    .task {
      store.send(.task)
    }
  }
}

