//
//  Cart.swift
//  ECommerceApp
//
//  Created by Ademola Fadumo on 22/06/2025.
//

import Foundation

nonisolated struct Cart: Identifiable, Hashable, Equatable {
    typealias ID = UUID
    
    let cartId: UUID
    let products: [Product]
    let createdAt: Date
    
    var id: ID {
        cartId
    }
}
