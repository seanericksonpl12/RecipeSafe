import SwiftUI
import SQLiteData
import ComposableArchitecture

@main
struct RecipeSafeApp: App {
  
  init() {
    prepareDependencies {
      $0.defaultDatabase = try! PersistenceController.appDatabase()
    }
  }
  
  var body: some Scene {
    WindowGroup {
      LaunchView(store: Store(initialState: LaunchReducer.LaunchState()) {
        LaunchReducer()
      })
    }
  }
}
