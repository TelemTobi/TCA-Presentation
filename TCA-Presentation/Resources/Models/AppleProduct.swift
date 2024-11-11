//
//  AppleProduct.swift
//  Demo
//
//  Created by Telem Tobi on 10/11/2024.
//

import Foundation

struct AppleProduct: Hashable, Equatable {
    let name: String
    let emoji: String
}

extension AppleProduct {
    static let mock: [AppleProduct] = [
        AppleProduct(name: "Macbook", emoji: "💻"),
        AppleProduct(name: "iPhone", emoji: "📱"),
        AppleProduct(name: "Apple Watch", emoji: "⌚️"),
        AppleProduct(name: "Magic Keyboard", emoji: "⌨️"),
        AppleProduct(name: "Magic Mouse", emoji: "🖱️")
    ]
}
