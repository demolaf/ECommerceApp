//
//  SecurityRemoteDatasource.swift
//  ECommerceApp
//
//  Created by Ademola Fadumo on 21/06/2025.
//

import Foundation

protocol SecurityRemoteDatasource {
    func signup(email: String, password: String) async -> Result<User, Error>
    func login(email: String, password: String) async -> Result<User, Error>
    func logout() throws
}
