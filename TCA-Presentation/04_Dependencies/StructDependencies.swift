//
//  StructDependencies.swift
//  Demo
//
//  Created by Telem Tobi on 10/11/2024.
//

import SwiftUI

struct StructDependenciesView: View {
    
    let viewModel: StructDependenciesViewModel
    
    init(viewModel: StructDependenciesViewModel) {
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
class StructDependenciesViewModel {
    
    private(set) var viewState: ViewState = .loading
    private let client: AppleProductsClient
    
    init(client: AppleProductsClient) {
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

struct AppleProductsClient {
    var fetchProducts: @Sendable () async -> Result<[AppleProduct], Error>
}

extension AppleProductsClient {
    
    static let happyFlow = Self(
        fetchProducts: {
            try? await Task.sleep(for: .seconds(1))
            return .success(AppleProduct.mock)
        }
    )
    
    static let emptyState = Self(
        fetchProducts: {
            try? await Task.sleep(for: .seconds(1))
            return .success([])
        }
    )
    
    static let error = Self(
        fetchProducts: {
            try? await Task.sleep(for: .seconds(1))
            return .failure(NSError())
        }
    )
}

#Preview("Happy Flow") {
    StructDependenciesView(
        viewModel: .init(client: .happyFlow)
    )
}

#Preview("Empty State") {
    StructDependenciesView(
        viewModel: .init(client: .emptyState)
    )
}

#Preview("Error") {
    StructDependenciesView(
        viewModel: .init(client: .error)
    )
}
