import SwiftUI
import SQLiteData
import ComposableArchitecture
import EmbraceIO

@main
struct RecipeSafeApp: App {
  
  init() {
    setupEmbrace()
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
  
  func setupEmbrace() {
    let options = Embrace.Options(appId: "refmr")
    do {
      try Embrace.setup(options: options).start()
    } catch {
      Logger.log("Failed to setup Embrace with error: \(error)")
    }
  }
}
