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
    struct State: Equatable, Identifiable {
        var description = ""
        let id: UUID
        var isComplete = false
    }
    
    enum Action: BindableAction, Sendable {
        case binding(BindingAction<State>)
    }
    
    var body: some Reducer<State, Action> {
        BindingReducer()
    }
}

struct TodoView: View {
    
    @Bindable var store: StoreOf<Todo>
    
    var body: some View {
        HStack {
            Button {
                store.isComplete.toggle()
            } label: {
                Image(systemName: store.isComplete ? "checkmark.square" : "square")
            }
            .buttonStyle(.plain)
            
            TextField("Untitled Todo", text: $store.description)
        }
        .foregroundColor(store.isComplete ? .gray : nil)
    }
}
