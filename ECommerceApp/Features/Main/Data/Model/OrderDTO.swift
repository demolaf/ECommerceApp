//
//  OrderDTO.swift
//  ECommerceApp
//
//  Created by Ademola Fadumo on 22/06/2025.
//

import Foundation

nonisolated struct OrderDTO: Codable {
    let uid: String
    var status: String = "pending" // pending, started, completed
    let userId: String
    let products: [ProductDTO]
    let createdAt: String
    
    var toEntity: Order {
        Order(id: UUID(uuidString: uid) ?? UUID(), status: Order.OrderStatus(rawValue: status) ?? .pending, userId: userId, products: products.map(\.toEntity), createdAt: createdAt.iso8601ToDate())
    }
    
    static func fromEntity(_ order: Order) -> Self {
        OrderDTO(uid: order.id.uuidString, status: order.status.rawValue, userId: order.userId, products: order.products.map(ProductDTO.fromEntity), createdAt: order.createdAt.toISO8601String())
    }
    
    static func fromMO(_ mo: OrderMO) -> Self {
        let products: [ProductDTO] = (mo.products?.allObjects as? [ProductMO])?
            .map(ProductDTO.fromMO) ?? []

        return OrderDTO(uid: mo.uid ?? "", status: mo.status ?? "", userId: mo.userId ?? "", products: products, createdAt: mo.createdAt?.toISO8601String() ?? "")
    }
}
