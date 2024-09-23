//
//  TCASearchTextField.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 9/21/24.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct SearchTextFieldReducer {
    
    enum ButtonState: String {
        case refresh = "arrow.counterclockwise"
        case cancel = "x.circle.fill"
        case none = ""
    }
    
    @ObservableState
    struct State {
        var text: String = ""
        var isFocused: Bool = false
        var buttonState: ButtonState = .none
        var showCancel: Bool = false
        var hasMadeSearch: Bool = false
    }
    
    enum Action {
        case textChanged(String)
        case isFocusedChanged(Bool)
        case isLoadingChanged
        case submitted
        case secondaryButtonTapped
        case refreshAction
        case clearAction
        case cancelButtonTapped
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .textChanged(let str):
                state.text = str
                return .none
            case .isFocusedChanged(let bool):
                withAnimation {
                    state.isFocused = bool
                    state.showCancel = state.isFocused
                    state.buttonState = state.isFocused ? .cancel : .none
                }
                return .none
            case .isLoadingChanged:
                return .none
            case .submitted:
                print("submitted from text field")
                state.isFocused = false
                
                return .none
            case .secondaryButtonTapped:
                switch state.buttonState {
                case .refresh:
                    return .send(.refreshAction)
                case .cancel:
                    return .send(.clearAction)
                case .none:
                    return .none
                }
            case .cancelButtonTapped:
                state.showCancel = false
                state.isFocused = false
            default:
                return .none
            }
            return .none
            
        }
    }
}

struct TCASearchTextField: View {

    @Perception.Bindable var store: StoreOf<SearchTextFieldReducer>
    @FocusState var focus: Bool
    
    var body: some View {
        WithPerceptionTracking {
            HStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(Color("gray2"))
                        .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: -4))
                    TextField("", text: $store.text.sending(\.textChanged), prompt: Text("").foregroundColor(Color("gray2")))
                        .focused($focus)
                        .bind($store.isFocused.sending(\.isFocusedChanged), to: $focus)
                        .textFieldStyle(PlainTextFieldStyle())
                        .onSubmit {
                            store.send(.submitted)
                        }
                    Spacer()
                    if store.buttonState != .none {
                        Button {
                            store.send(.secondaryButtonTapped)
                        } label: {
                            Image(systemName: store.buttonState.rawValue)
                                .padding(8)
                        }
                    }
                }
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color("gray1"))
                }
                if store.showCancel {
                    Button {
                        store.send(.cancelButtonTapped, animation: .smooth)
                    } label: {
                        Text("Cancel")
                    }
                    .transition(.move(edge: .trailing).combined(with: .offset(x: 50, y: 0)))
                }
            }
        }
    }
}

#Preview {
    TCASearchTextField(
        store: Store(initialState: SearchTextFieldReducer.State()) {
            SearchTextFieldReducer()
                ._printChanges()
        }
    )
}

