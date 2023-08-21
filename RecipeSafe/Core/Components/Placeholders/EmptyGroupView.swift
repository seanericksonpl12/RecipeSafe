//
//  EmptyGroupView.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 8/21/23.
//

import SwiftUI

struct EmptyGroupView: View {
    var body: some View {
        VStack {
            Text("Can't find any ungrouped recipes. Add more for them to appear here!")
                .multilineTextAlignment(.center)
                .font(.callout)
                .foregroundColor(.gray)
                .padding()
            Image("logo-clear")
                .resizable()
                .scaledToFit()
                .opacity(0.3)
                .padding(EdgeInsets(top: 10, leading: 30, bottom: 10, trailing: 30))
        }
    }
}

struct EmptyGroupView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyGroupView()
    }
}
