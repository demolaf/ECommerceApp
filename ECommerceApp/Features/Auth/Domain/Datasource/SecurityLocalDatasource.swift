//
//  SecurityLocalDatasource.swift
//  ECommerceApp
//
//  Created by Ademola Fadumo on 21/06/2025.
//

import Foundation

protocol SecurityLocalDatasource {
    func fetchUserSession() -> Result<UserDTO?, Error>
    @discardableResult func saveUserSession(user: UserDTO) throws -> UserDTO
    func clearUserSession() throws
}
