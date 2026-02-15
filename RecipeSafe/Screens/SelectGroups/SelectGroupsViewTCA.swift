import ComposableArchitecture
import SwiftUI

struct SelectGroupsViewTCA: View {
  
  @Bindable var store: StoreOf<SelectGroupsReducer>
  
  init(store: StoreOf<SelectGroupsReducer>) {
    self.store = store
  }
  
  var body: some View {
    NavigationStack {
      GeometryReader { geo in
        VStack {
          HStack {
            Text("group.new.add".localized)
              .font(.title)
              .fontWeight(.heavy)
              .padding()
            Spacer()
            Button("button.cancel".localized) {
              store.send(.cancel)
            }
            .padding()
          }
          // MARK: - Grid
          ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: (geo.size.width / 2.75)))]) {
              InsertGridButton(
                insertAction: { store.send(.addNewGroup) },
                width: (geo.size.width / 2.75),
                height: (geo.size.width / 2.75)
              )
              ForEach(store.groups) { item in
                Button {
                  store.send(.groupTapped(item))
                } label: {
                  GridButton(
                    isEditing: .constant(false),
                    geoProxy: geo,
                    group: item,
                    deleteAction: { }
                  )
                }
              }
            }
          }
          .scrollContentBackground(.hidden)
        }
        .sheet(item: $store.scope(state: \.destination?.newGroup, action: \.destination.newGroup)) { store in
          NavigationStack {
            NewGroupViewTCA(store: store)
          }
        }
      }
    }
    .task {
      store.send(.task)
    }
  }
}

