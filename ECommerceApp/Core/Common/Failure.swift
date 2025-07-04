//
//  Failure.swift
//  ECommerceApp
//
//  Created by Ademola Fadumo on 21/06/2025.
//

enum Failure: Error {
    case createDocument
    case getDocument
    case notFoundInDatabase
    case databaseError(String)
}
