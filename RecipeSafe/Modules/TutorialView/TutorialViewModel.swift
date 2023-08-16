//
//  TutorialViewModel.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 8/15/23.
//

import Foundation
import SwiftUI

@MainActor class TutorialViewModel: ObservableObject {
    
    // MARK: - Wrapped
    @Published var tabSelection: Int = 1
    
    // MARK: - Private
    private var dismiss: Binding<Bool>
    
    // MARK: - Init
    init(dismiss: Binding<Bool>) {
        self.dismiss = dismiss
    }
    
}

// MARK: - Functions
extension TutorialViewModel {
    
    func toPage(_ page: Int) {
        withAnimation {
            self.tabSelection = page
        }
    }
    
    func endTutorial() {
        self.dismiss.wrappedValue = false
    }
    
    func setColors(colorMode: ColorScheme) {
        if colorMode == .light {
            UIPageControl.appearance().currentPageIndicatorTintColor = .black
            UIPageControl.appearance().pageIndicatorTintColor = .gray
        } else if colorMode == .dark {
            UIPageControl.appearance().currentPageIndicatorTintColor = .white
            UIPageControl.appearance().pageIndicatorTintColor = .gray
        }
    }
}
