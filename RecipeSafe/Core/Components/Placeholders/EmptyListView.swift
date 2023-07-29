//
//  EmptyListView.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 7/29/23.
//

import SwiftUI

struct EmptyListView: View {
    var body: some View {
        VStack {
            Spacer()
            Text("empty.title".localized)
                .font(.title)
                .fontWeight(.heavy)
                .foregroundColor(.gray)
                .padding()
            Text("empty.desc".localized)
                .font(.caption)
                .foregroundColor(.gray)
            Spacer()
        }
    }
}

struct EmptyListView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyListView()
    }
}
