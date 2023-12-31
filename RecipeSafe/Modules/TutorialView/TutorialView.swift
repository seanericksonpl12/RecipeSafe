//
//  TutorialView.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 8/15/23.
//

import SwiftUI

struct TutorialView: View {
    
    @Environment(\.colorScheme) private var colorMode
    @StateObject var viewModel: TutorialViewModel
    
    // MARK: - Body
    var body: some View {
        TabView(selection: $viewModel.tabSelection) {
            TutorialPageView(text: "tutorial.page.1".localized,
                             imageName: "tutorial-img1",
                             nextAction: { viewModel.toPage(2) })
                .tabItem {
                    Label("tutorial.title".localized, systemImage: "circle")
                }
                .tag(1)
            TutorialPageView(text: "tutorial.page.2".localized,
                             imageName: "tutorial-img2",
                             nextAction: { viewModel.toPage(3) })
                .tabItem {
                    Label("tutorial.title".localized, systemImage: "circle")
                }
                .tag(2)
            TutorialPageView(text: "tutorial.page.3".localized,
                             imageName: "tutorial-img3",
                             nextAction: { viewModel.toPage(4) })
                .tabItem {
                    Label("tutorial.title".localized, systemImage: "circle")
                }
                .tag(3)
            TutorialPageView(text: "tutorial.page.4".localized,
                             imageName: "tutorial-img4",
                             doneAction: { viewModel.endTutorial() })
                .tabItem {
                    Label("tutorial.title".localized, systemImage: "circle")
                }
                .tag(4)
            
        }
        .tabViewStyle(.page)
        .onAppear {
            viewModel.setColors(colorMode: colorMode)
        }
    }
    
    // MARK: - Page One
    var pageOne: some View {
        
        VStack {
            Text("tutorial.title".localized)
                .font(.title)
                .fontWeight(.heavy)
                .padding()
            List {
                Section {
                    Image("tutorial-img1")
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(10)
                        .padding(.bottom)
                }
                Section {
                    HStack {
                        Spacer()
                        Text("tutorial.pageone".localized)
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                }
            }
            .scrollDisabled(true)
            HStack {
                Spacer()
                Button {
                    viewModel.toPage(2)
                } label: {
                    Text("button.next".localized)
                        .frame(width: 150, height: 35)
                        .foregroundColor(.white)
                        .background(.secondary, in: RoundedRectangle(cornerRadius: 10))
                }
                
                Button {
                    withAnimation {
                        viewModel.endTutorial()
                    }
                } label: {
                    Text("button.done".localized)
                        .frame(width: 150, height: 35)
                        .foregroundColor(.white)
                        .background(.secondary, in: RoundedRectangle(cornerRadius: 10))
                }
                Spacer()
            }
            .padding(.bottom, 70)
            .frame(maxHeight: 40, alignment: .bottom)
            
        }
    }
    
    // MARK: - Page Two
    var pageTwo: some View {
        VStack {
            Text("tutorial.title".localized)
                .font(.title)
                .fontWeight(.heavy)
                .padding()
            List {
                Section {
                    Image("tutorial-img2")
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(10)
                        .padding(.bottom)
                }
                Section {
                    HStack {
                        Spacer()
                        Text("tutorial.pagetwo".localized)
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                }
            }
            .scrollDisabled(true)
            HStack {
                Spacer()
                Button {
                    withAnimation {
                        viewModel.endTutorial()
                    }
                } label: {
                    Text("button.done".localized)
                        .frame(width: 150, height: 35)
                        .foregroundColor(.white)
                        .background(.secondary, in: RoundedRectangle(cornerRadius: 10))
                }
                Spacer()
            }
            .padding(.bottom, 70)
            .frame(maxHeight: 40, alignment: .bottom)
        }
    }
}
