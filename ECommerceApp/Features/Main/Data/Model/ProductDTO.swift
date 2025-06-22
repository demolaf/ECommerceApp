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

    var toEntity: Product {
        let id = UUID(uuidString: uid) ?? UUID()
        return Product(id: id, photoUrl: photoUrl, name: name, price: price)
    }

    static func fromEntity(_ product: Product) -> Self {
        return ProductDTO(
            uid: product.id.uuidString,
            photoUrl: product.photoUrl,
            name: product.name,
            price: product.price
        )
    }

    static func fromMO(_ mo: ProductMO) -> Self {
        return ProductDTO(
            uid: mo.uid ?? UUID().uuidString,
            photoUrl: mo.photoUrl ?? "",
            name: mo.name ?? "",
            price: mo.price
        )
    }
}
