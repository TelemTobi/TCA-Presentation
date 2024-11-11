//
//  ProtocolDepencies.swift
//  Demo
//
//  Created by Telem Tobi on 10/11/2024.
//

import SwiftUI

struct ProtocolDependenciesView: View {
    
    let viewModel: ProtocolDependenciesViewModel
    
    init(viewModel: ProtocolDependenciesViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                switch viewModel.viewState {
                case .loading:
                    ProgressView()
                    
                case let .loaded(products):
                    if products.isEmpty {
                        ContentUnavailableView(
                            "Hmm.. No product found",
                            systemImage: "binoculars.fill"
                        )
                    } else {
                        List(products, id: \.self) { product in
                            HStack(spacing: 16) {
                                Text(product.emoji)
                                    .font(.largeTitle)
                                
                                Text(product.name)
                                    .font(.title3)
                                    .fontWeight(.medium)
                            }
                            .padding(.vertical, 5)
                        }
                    }
                    
                case .error:
                    ContentUnavailableView(
                        "Whoops, something's wrong",
                        systemImage: "xmark.icloud.fill"
                    )
                }
            }
            .navigationTitle("Apple Products")
            .animation(.smooth, value: viewModel.viewState)
            .onAppear(perform: viewModel.onAppear)
        }
    }
}

@Observable
class ProtocolDependenciesViewModel {
    
    private(set) var viewState: ViewState = .loading
    private let client: AppleProductsClientProtocol
    
    init(client: AppleProductsClientProtocol) {
        self.client = client
    }
    
    func onAppear() {
        Task {
            let result = await client.fetchProducts()
            
            switch result {
            case let .success(products):
                viewState = .loaded(products)
                
            case .failure:
                viewState = .error
            }
        }
    }
    
    enum ViewState: Equatable {
        case loading
        case loaded([AppleProduct])
        case error
    }
}

// MARK: - Live

protocol AppleProductsClientProtocol: AnyObject {
    func fetchProducts() async -> Result<[AppleProduct], Error>
}

class LiveAppleProductsClient: AppleProductsClientProtocol {
    
    func fetchProducts() async -> Result<[AppleProduct], Error> {
        try? await Task.sleep(for: .seconds(1))
        return .success(AppleProduct.mock)
    }
}

// MARK: - Empty

// ...

#Preview {
    ProtocolDependenciesView(
        viewModel: .init(client: LiveAppleProductsClient())
    )
}
