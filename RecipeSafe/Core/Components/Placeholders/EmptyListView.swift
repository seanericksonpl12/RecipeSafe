//
//  EmptyListView.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 7/29/23.
//

import SwiftUI

struct EmptyListView: View {
    
    // MARK: - Properties
    var description: String
    
    // MARK: - Body
    var body: some View {
        VStack {
            Spacer()
            Text("empty.title".localized)
                .font(.title)
                .fontWeight(.heavy)
                .foregroundColor(.gray)
                .padding()
            Text(description)
                .font(.caption)
                .foregroundColor(.gray)
            Image("logo-clear")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: 150, maxHeight: 150)
                .opacity(0.5)
                .padding(.top, 50)
            Spacer()
        }
    }
}
