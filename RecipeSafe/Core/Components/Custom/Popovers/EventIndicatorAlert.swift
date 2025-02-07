//
//  EventIndicatorAlert.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 2/7/25.
//

import SwiftUI

struct EventIndicatorAlert: View {
    
    let text: String
    @State private var isVisible = false
    
    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.gray.opacity(0.75))
            .frame(width: 200, height: 200)
            .overlay {
                VStack {
                    Text(text)
                        .font(.title)
                        .padding(.top)
                    Image(systemName: "checkmark.diamond")
                        .resizable()
                        .frame(width: 75, height: 75)
                        .padding()
                }
            }
    }
}

struct EventIndicator_Preview: PreviewProvider {
    static var previews: some View {
        EventIndicatorAlert(text: "success")
    }
}
