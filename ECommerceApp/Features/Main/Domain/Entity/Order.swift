//
//  Order.swift
//  ECommerceApp
//
//  Created by Ademola Fadumo on 22/06/2025.
//

import Foundation

nonisolated struct Order: Identifiable, Hashable, Equatable {
    let id: UUID
    let status: String
    let userId: String
    let products: [Product]
    let createdAt: Date
}
