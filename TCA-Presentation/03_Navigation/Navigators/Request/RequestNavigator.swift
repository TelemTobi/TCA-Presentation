//
//  RequestNavigator.swift
//  TCA-Demo
//
//  Created by Telem Tobi on 08/02/2024.
//

import Foundation
import ComposableArchitecture

@Reducer
struct RequestNavigator {
    
    @ObservableState
    struct State: Equatable {
        var root = Amount.State()
        var path = StackState<Path.State>()
        
        var request = Request()
        
        var subtitle: String {
            [request.amount?.description, request.contact, request.reason]
                .compactMap { $0 }
                .joined(separator: " · ")
        }
    }
    
    enum Action {
        case root(Amount.Action)
        case path(StackAction<Path.State, Path.Action>)
        case didTapClose
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: \.root, action: \.root, child: Amount.init)
        
        Reduce { state, action in
            switch action {
            case let .root(.didSelectAmount(amount)):
                state.request.amount = amount
                state.path.append(.contacts(Contacts.State()))
                return .none
                
            case let .path(.element(_, action: .contacts(.didSelectContact(contact)))):
                state.request.contact = contact
                state.path.append(.reason(Reason.State()))
                return .none
                
            case let .path(.element(_, action: .reason(.didSelectReason(reason)))):
                state.request.reason = reason
                // Pass the transfer to an approval module or whatever..
                return .none
                
            case .didTapClose:
                return .dismiss
                
            case .root, .path:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}

extension RequestNavigator {
    
    @Reducer(state: .equatable)
    enum Path {
        case contacts(Contacts)
        case reason(Reason)
    }
    
    struct Request: Equatable {
        var contact: String?
        var amount: Float?
        var reason: String?
    }
}
