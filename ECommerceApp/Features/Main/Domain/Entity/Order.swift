//
//  Order.swift
//  ECommerceApp
//
//  Created by Ademola Fadumo on 22/06/2025.
//

import Foundation
import UIKit

nonisolated struct Order: Identifiable, Hashable, Equatable {
    enum OrderStatus: String {
        case pending
        case started
        case completed
        case failed
        
        var title: String {
            switch self {
            case .pending: "Pending"
            case .started: "Started"
            case .completed: "Completed"
            case .failed: "Failed"
            }
        }
        
        var color: UIColor {
            switch self {
            case .pending: .yellow
            case .started: .label
            case .completed: .green
            case .failed: .red
            }
        }
    }
    
    let id: UUID
    let status: OrderStatus
    let userId: String
    let products: [Product]
    let createdAt: Date
}
