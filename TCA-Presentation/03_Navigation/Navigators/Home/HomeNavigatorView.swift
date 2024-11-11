//
//  HomeNavigatorView.swift
//  TCA-Demo
//
//  Created by Telem Tobi on 09/02/2024.
//

import SwiftUI
import ComposableArchitecture

extension HomeNavigator {
    struct ContentView: View {
        
        @Bindable var store: StoreOf<HomeNavigator>
        
        var body: some View {
            NavigationStack {
                HomeView(store: store.scope(state: \.root, action: \.root))
                    .fullScreenCover(
                        item: $store.scope(state: \.destination, action: \.destination),
                        content: { store in
                            switch store.case {
                            case let .transfer(store):
                                TransferNavigator.ContentView(store: store)
                                
                            case let .request(store):
                                RequestNavigator.ContentView(store: store)
                            }
                        }
                    )
            }
        }
    }
}

#Preview {
    HomeNavigator.ContentView(
        store: .init(
            initialState: HomeNavigator.State(),
            reducer: HomeNavigator.init
        )
    )
}
