//
//  Todo.swift
//  Demo
//
//  Created by Telem Tobi on 11/11/2024.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct Todo {
    
    @ObservableState
    struct State: Equatable, Identifiable, Codable {
        let id: UUID
        var description = ""
        var isComplete = false
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case onToggle
    }
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .onToggle:
                state.isComplete.toggle()
                return .none
                
            case .binding:
                return .none
            }
        }
    }
}

struct TodoView: View {
    
    @Bindable var store: StoreOf<Todo>
    
    var body: some View {
        HStack {
            Button {
                store.send(.onToggle)
            } label: {
                Image(systemName: store.isComplete ? "checkmark.square" : "square")
            }
            .buttonStyle(.plain)
            
            TextField("Untitled Todo", text: $store.description)
        }
        .foregroundColor(store.isComplete ? .gray : nil)
    }
}

#Preview {
    TodoView(
        store: .init(
            initialState: Todo.State(id: UUID(), description: "Untitled Todo"),
            reducer: Todo.init
        )
    )
}
