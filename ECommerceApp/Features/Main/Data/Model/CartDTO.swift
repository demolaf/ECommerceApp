//
//  CartDTO.swift
//  ECommerceApp
//
//  Created by Ademola Fadumo on 22/06/2025.
//

import Foundation

nonisolated struct CartDTO: Codable {
    let cartId: String
    let products: [ProductDTO]
    let createdAt: String
    
    var toEntity: Cart {
        Cart(cartId: UUID(uuidString: cartId) ?? UUID(), products: products.map(\.toEntity), createdAt: createdAt.iso8601ToDate())
    }
    
    static func fromEntity(_ cart: Cart) -> Self {
        CartDTO(cartId: cart.id.uuidString, products: cart.products.map(ProductDTO.fromEntity), createdAt: cart.createdAt.toISO8601String())
    }
    
    static func fromMO(_ mo: CartMO) -> Self {
        let products: [ProductDTO] = (mo.products?.allObjects as? [ProductMO])?
            .map(ProductDTO.fromMO) ?? []

        return CartDTO(cartId: mo.cartId ?? "", products: products, createdAt: mo.createdAt?.toISO8601String() ?? "")
    }
}
