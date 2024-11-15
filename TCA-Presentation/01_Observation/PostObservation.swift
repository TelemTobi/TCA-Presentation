//
//  PostObservation.swift
//  Demo
//
//  Created by Telem Tobi on 10/11/2024.
//

import SwiftUI

struct PostObservationView: View {
    
    let viewModel = PostObservationViewModel()
    
    var body: some View {
        let _ = Self._printChanges()
        
        VStack {
            if viewModel.isVisible {
                Text(viewModel.counter.description)
                    .font(.largeTitle)
            }
            
            HStack {
                Button {
                    viewModel.onDecrementTap()
                } label: {
                    Text("-")
                        .frame(maxWidth: .infinity)
                }
                
                Button {
                    viewModel.onIncrementTap()
                } label: {
                    Text("+")
                        .frame(maxWidth: .infinity)
                }
            }
            .font(.title)
            .buttonStyle(.bordered)
            .frame(maxWidth: .infinity)
            
            
            Button {
                viewModel.onToggleVisibilityTap()
            } label: {
                Text("Toggle Visibility")
                    .frame(maxWidth: .infinity)
            }
            .font(.title2)
            .buttonStyle(.borderedProminent)
        }
        .frame(width: 180)
        .animation(.snappy, value: viewModel.isVisible)
    }
}

@Observable
class PostObservationViewModel: ObservableObject {
    
    private(set) var counter: Int = .zero
    private(set) var isVisible: Bool = true
    
    func onIncrementTap() {
        counter += 1
    }
    
    func onDecrementTap() {
        counter -= 1
    }
    
    func onToggleVisibilityTap() {
        isVisible.toggle()
    }
}

#Preview {
    PostObservationView()
}
