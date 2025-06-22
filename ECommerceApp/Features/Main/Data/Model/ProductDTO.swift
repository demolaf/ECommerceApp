//
//  ProductDTO.swift
//  ECommerceApp
//
//  Created by Ademola Fadumo on 21/06/2025.
//

import Foundation

nonisolated struct ProductDTO: Codable {
    let uid: String
    let photoUrl: String
    let name: String
    let price: Double
    
    func toEntity() -> Product {
        Product(id: UUID(uuidString: uid) ?? .init(), photoUrl: photoUrl, name: name, price: price)
    }
    
    static func fromEntity(_ product: Product) -> Self {
        ProductDTO(uid: product.id.uuidString, photoUrl: product.photoUrl, name: product.name, price: product.price)
    }
    
    static func fromMO(_ mo: ProductMO) -> Self {
        ProductDTO(uid: mo.uid ?? "", photoUrl: mo.photoUrl ?? "", name: mo.name ?? "", price: mo.price)
    }
}
