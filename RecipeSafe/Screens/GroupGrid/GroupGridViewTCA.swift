import ComposableArchitecture
import Dependencies
import SwiftUI

struct GroupGridViewTCA: View {
  
  @Bindable var store: StoreOf<GroupGridReducer>
  
  init(store: StoreOf<GroupGridReducer>) {
    self.store = store
  }
  
  // MARK: - Body
  var body: some View {
    NavigationStack(path: $store.scope(state: \.navPath, action: \.navPath)) {
      GeometryReader { geo in
        ScrollView {
          LazyVGrid(columns: [GridItem(.adaptive(minimum: (CGFloat(geo.size.width) / 2.75)))]) {
            if store.editingEnabled {
              InsertGridButton(
                insertAction: { store.send(.addGroup) },
                width: (geo.size.width / 2.75),
                height: (geo.size.width / 2.75)
              )
            }
            ForEach(store.groups) { item in
              if store.editingEnabled {
                GridButton(
                  isEditing: $store.editingEnabled,
                  geoProxy: geo,
                  group: item,
                  deleteAction: { store.send(.deleteGroup(item)) }
                )
              } else {
                Button {
                  store.send(.groupTapped(item))
                } label: {
                  GridButton(
                    isEditing: $store.editingEnabled,
                    geoProxy: geo,
                    group: item,
                    deleteAction: { store.send(.deleteGroup(item)) }
                  )
                }
              }
            }
          }
          .padding(.leading)
          .padding(.trailing)
        }
        
        // MARK: - Background
        .scrollDisabled(store.groups.isEmpty && !store.editingEnabled)
        .scrollContentBackground(.hidden)
      }
      
      // MARK: - Toolbar
      .toolbar {
        ToolbarItem {
          Button(store.editingEnabled ? "button.done".localized : "button.edit".localized) {
            store.send(.toggleEdit)
          }
          .frame(width: 60, height: 60)
          .contentShape(Rectangle())
        }
      }
      .navigationBarTitleDisplayMode(.inline)
      .environment(\.editMode, .constant(store.editingEnabled ? EditMode.active : EditMode.inactive))
      .alert($store.scope(state: \.alert, action: \.alert))
      .sheet(item: $store.scope(state: \.destination?.newGroup, action: \.destination.newGroup)) { store in
        NavigationStack {
          NewGroupViewTCA(store: store)
        }
      }
      .popover(item: $store.scope(state: \.destination?.selectGroups, action: \.destination.selectGroups)) { store in
        SelectGroupsViewTCA(store: store)
      }
    } destination: { (path: StoreOf<GroupGridReducer.NavPath>) in
      switch path.case {
      case let .group(store):
        GroupViewTCA(store: store)
      case let .recipe(store):
        RecipeView(store: store)
      }
    }
    .task {
      store.send(.task)
    }
    .pageLoad(.groups)
    .emptyModifier(isHidden: store.groups.isEmpty && !store.editingEnabled, description: "empty.desc.2".localized)
  }
}
