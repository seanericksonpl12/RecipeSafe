//
//  LaunchView.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 2/18/25.
//

import ComposableArchitecture
import SwiftUI

struct LaunchView: View {
  
  @Bindable private var store: StoreOf<LaunchReducer>
  
  init(store: StoreOf<LaunchReducer>) {
    self.store = store
  }
  
  var body: some View {
    if store.animationFinished {
      ContentView(store: store.scope(state: \.contentState, action: \.content))
        .addKeyboardToEnvironment()
    } else {
      LaunchScreen(
        didFinishPlayingAnimation: $store.animationFinished.sending(\.didFinishPlayingAnimation),
        playAnimation: store.loadState == .loaded
      )
        .ignoresSafeArea()
        .task {
          store.send(.fetchAppConfig)
        }
    }
  }
}
