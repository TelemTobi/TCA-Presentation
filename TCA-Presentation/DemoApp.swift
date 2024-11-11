//
//  DemoApp.swift
//  TCA-Presentation
//
//  Created by Telem Tobi on 11/11/2024.
//

import SwiftUI

@main
struct DemoApp: App {
    var body: some Scene {
        WindowGroup {
//            PreObservationView()
            
//            ProtocolDependenciesView(
//                viewModel: .init(client: LiveAppleProductsClient())
//            )
            
            TodosView(
                store: .init(
                    initialState: Todos.State(),
                    reducer: Todos.init
                )
            )
        }
    }
}