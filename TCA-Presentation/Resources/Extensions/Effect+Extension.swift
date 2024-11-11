//
//  Effect+Extension.swift
//  TCA-Presentation
//
//  Created by Telem Tobi on 11/11/2024.
//

import ComposableArchitecture

extension Effect {
    
    static var dismiss: Self {
        @Dependency(\.dismiss) var dismiss
        return .run { _ in await dismiss() }
    }
}
