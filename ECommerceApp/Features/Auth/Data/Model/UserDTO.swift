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

    var toEntity: User {
        User(uid: uid, email: email, displayName: displayName)
    }

    static func fromEntity(_ user: User) -> Self {
        Self(uid: user.uid, email: user.email, displayName: user.displayName)
    }

    static func fromMO(_ mo: UserMO) -> Self {
        Self(
            uid: mo.uid ?? UUID().uuidString,
            email: mo.email ?? "",
            displayName: mo.displayName ?? ""
        )
    }
}
