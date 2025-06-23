//
//  FirebaseCollections.swift
//  ECommerceApp
//
//  Created by Ademola Fadumo on 23/06/2025.
//

import Foundation

enum FirebaseCollections: String {
    case products
    case orders
    
    var collectionPath: String {
        rawValue
    }
}
