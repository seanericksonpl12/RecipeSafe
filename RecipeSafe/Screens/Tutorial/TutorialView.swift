//
//  TutorialView.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 8/15/23.
//

import SwiftUI

struct TutorialView: View {
    
    @Environment(\.colorScheme) private var colorMode
    @Binding var dismiss: Bool
    
    @State private var tabSelection: Int = 1
    
    // MARK: - Body
    var body: some View {
        TabView(selection: $tabSelection) {
            TutorialPageView(text: "tutorial.page.1".localized,
                             imageName: "tutorial-img1",
                             nextAction: { toPage(2) })
                .tabItem {
                    Label("tutorial.title".localized, systemImage: "circle")
                }
                .tag(1)
            TutorialPageView(text: "tutorial.page.2".localized,
                             imageName: "tutorial-img2",
                             nextAction: { toPage(3) })
                .tabItem {
                    Label("tutorial.title".localized, systemImage: "circle")
                }
                .tag(2)
            TutorialPageView(text: "tutorial.page.3".localized,
                             imageName: "tutorial-img3",
                             nextAction: { toPage(4) })
                .tabItem {
                    Label("tutorial.title".localized, systemImage: "circle")
                }
                .tag(3)
            TutorialPageView(text: "tutorial.page.4".localized,
                             imageName: "tutorial-img4",
                             doneAction: { endTutorial() })
                .tabItem {
                    Label("tutorial.title".localized, systemImage: "circle")
                }
                .tag(4)
            
        }
        .tabViewStyle(.page)
        .onAppear {
            setColors(colorMode: colorMode)
        }
        .pageLoad(.tutorial)
    }
    
    func toPage(_ page: Int) {
        withAnimation {
            self.tabSelection = page
        }
    }
    
    func endTutorial() {
        self.dismiss = false
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
