//
//  Contacts.swift
//  TCA-Demo
//
//  Created by Telem Tobi on 06/02/2024.
//

import Foundation
import ComposableArchitecture

@Reducer
struct Contacts {
    
    @ObservableState
    struct State: Equatable {
        var counter = 0
    }
    
    enum Action {
        case onAppear
        case didSelectContact(String)
        case onIncrementTap
        case onDecrementTap
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
                
            case .onIncrementTap:
                state.counter += 1
                return .none
                
            case .onDecrementTap:
                state.counter -= 1
                return .none
                
            // MARK: Navigation actions
            case .didSelectContact:
                return .none
            }
        }
    }
}
