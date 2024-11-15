//
//  HomeNavigator.swift
//  TCA-Demo
//
//  Created by Telem Tobi on 09/02/2024.
//

import Foundation
import ComposableArchitecture

@Reducer
struct HomeNavigator {
    
    @ObservableState
    struct State: Equatable {
        var root = Home.State()
        @Presents var destination: Destination.State?
    }
    
    enum Action {
        case root(Home.Action)
        case destination(PresentationAction<Destination.Action>)
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: \.root, action: \.root, child: Home.init)
        
        Reduce { state, action in
            switch action {
            case .root(.onTransferTap):
                state.destination = .transfer(TransferNavigator.State())
                return .none
                
            case .root(.onRequestTap):
                state.destination = .request(RequestNavigator.State())
                return .none
                
            case .root, .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

extension HomeNavigator {
    
    @Reducer(state: .equatable)
    enum Destination {
        case transfer(TransferNavigator)
        case request(RequestNavigator)
    }
}
