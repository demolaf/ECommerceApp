//
//  UserDTO.swift
//  ECommerceApp
//
//  Created by Ademola Fadumo on 21/06/2025.
//

import Foundation

nonisolated struct UserDTO: Codable {
    let uid: String
    let email: String
    let displayName: String
    
    func toEntity() -> User {
        User(uid: uid, email: email, displayName: displayName)
    }
    
    static func fromEntity(_ user: User) -> UserDTO {
        UserDTO(uid: user.uid, email: user.email, displayName: user.displayName)
    }
    
    static func fromMO(_ mo: UserMO) -> UserDTO {
        UserDTO(uid: mo.uid ?? "", email: mo.email ?? "", displayName: mo.displayName ?? "")
    }
}
