//
//  Product.swift
//  ECommerceApp
//
//  Created by Ademola Fadumo on 21/06/2025.
//

import Foundation

nonisolated struct Product: Identifiable, Hashable, Equatable {
    let id: UUID
    let photoUrl: String
    let name: String
    let price: Double
}
