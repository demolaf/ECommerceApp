//
//  SecurityRemoteDatasourceImpl.swift
//  ECommerceApp
//
//  Created by Ademola Fadumo on 21/06/2025.
//

import Foundation
import FirebaseAuth

class SecurityRemoteDatasourceImpl: SecurityRemoteDatasource {
    init(firebaseAuth: Auth) {
        self.firebaseAuth = firebaseAuth
    }
    
    private let firebaseAuth: Auth
    
    func signup(email: String, password: String) async -> Result<User, Error> {
        do {
            let result = try await firebaseAuth.createUser(withEmail: email, password: password)
            let user = UserDTO(uid: result.user.uid, email: result.user.email ?? "", displayName: result.user.displayName ?? "").toEntity()
            return .success(user)
        } catch {
            return .failure(error)
        }
    }
    
    func login(email: String, password: String) async -> Result<User, Error> {
        do {
            let result = try await firebaseAuth.signIn(withEmail: email, password: password)
            let user = UserDTO(uid: result.user.uid, email: result.user.email ?? "", displayName: result.user.displayName ?? "").toEntity()
            return .success(user)
        } catch {
            return .failure(error)
        }
    }
}
