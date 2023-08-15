//
//  SelectGroupsPopover.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 8/14/23.
//

import SwiftUI

struct SelectGroupsPopover: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [SortDescriptor(\.title)],
        animation: .easeIn) private var groups: FetchedResults<GroupItem>
    @State private var editBinding: Bool = true
    @State private var notEditBinding: Bool = false
    var selectionAction: (GroupItem) -> Void
    var cancelAction: () -> Void
    
    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                VStack {
                    HStack {
                        Text("Save in Group")
                            .font(.title)
                            .fontWeight(.heavy)
                            .padding()
                        Spacer()
                        Button("button.cancel".localized) {
                            cancelAction()
                        }
                        .padding()
                    }
                    // MARK: - Grid
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: (geo.size.width / 2.75)))]) {
                            ForEach(groups) { item in
                                GridButton(isEditing: $notEditBinding, geoProxy: geo, group: item, deleteAction: {})
                                    .onTapGesture {
                                        selectionAction(item)
                                    }
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .background {
                        Image("logo-background")
                            .resizable()
                            .scaledToFill()
                            .frame(width: geo.size.width + geo.safeAreaInsets.leading + geo.safeAreaInsets.trailing)
                            .ignoresSafeArea(.all)
                            .opacity(0.3)
                    }
                }
            }
        }
    }
}
