//
//  SecurityRepository.swift
//  ECommerceApp
//
//  Created by Ademola Fadumo on 21/06/2025.
//

import Foundation

protocol SecurityRepository {
    func checkSessionExists() -> Result<User, Error>
    func signup(email: String, password: String) async -> Result<User, Error>
    func login(email: String, password: String) async -> Result<User, Error>
    func logout()
}
