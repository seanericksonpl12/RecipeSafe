//
//  TutorialPageView.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 8/17/23.
//

import SwiftUI

struct TutorialPageView: View {
    
    // MARK: - Properties
    var text: String
    var imageName: String
    
    // MARK: - Button Actions
    var nextAction: (() -> Void)?
    var doneAction: (() -> Void)?
    
    // MARK: - Body
    var body: some View {
        VStack {
            Text("tutorial.title".localized)
                .font(.title)
                .fontWeight(.heavy)
                .padding()
            List {
                Section {
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(10)
                        .padding(.bottom)
                
                    HStack {
                        Spacer()
                        Text(text)
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                }
            }
            .listRowSeparator(.hidden)
            .padding(.bottom, 60)
            
            HStack {
                Spacer()
                Button {
                    if let action = nextAction {
                        action()
                    } else if let action = doneAction {
                        action()
                    }
                } label: {
                    Text(nextAction != nil ? "button.next".localized : "button.done".localized)
                        .frame(width: 150, height: 35)
                        .foregroundColor(.white)
                        .background(.secondary, in: RoundedRectangle(cornerRadius: 10))
                }
                Spacer()
            }
            .padding(.bottom, 50)
            .frame(maxHeight: 30, alignment: .bottom)
        }
    }
}
