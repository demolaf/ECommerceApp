//
//  OrderDTO.swift
//  ECommerceApp
//
//  Created by Ademola Fadumo on 22/06/2025.
//

import Foundation

nonisolated struct OrderDTO: Codable {
    let uid: String
    let status: String
    let userId: String
    let products: [ProductDTO]
    let createdAt: Date
    
    var toEntity: Order {
        Order(id: UUID(uuidString: uid) ?? UUID(), status: status, userId: userId, products: products.map(\.toEntity), createdAt: createdAt)
    }
    
    static func fromEntity(_ order: Order) -> Self {
        OrderDTO(uid: order.id.uuidString, status: order.status, userId: order.userId, products: order.products.map(ProductDTO.fromEntity), createdAt: order.createdAt)
    }
    
    static func fromMO(_ mo: OrderMO) -> Self {
        let products: [ProductDTO] = (mo.products?.allObjects as? [ProductMO])?
            .map(ProductDTO.fromMO) ?? []

        return OrderDTO(uid: mo.uid ?? "", status: mo.status ?? "", userId: mo.userId ?? "", products: products, createdAt: mo.createdAt ?? .init())
    }
}
