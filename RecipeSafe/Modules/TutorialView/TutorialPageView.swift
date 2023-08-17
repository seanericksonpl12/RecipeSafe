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
                }
                Section {
                    HStack {
                        Spacer()
                        Text(text)
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                }
            }
            .scrollDisabled(true)
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
            .padding(.bottom, 70)
            .frame(maxHeight: 40, alignment: .bottom)
        }
    }
}
