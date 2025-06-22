//
//  SecurityRepositoryImpl.swift
//  ECommerceApp
//
//  Created by Ademola Fadumo on 21/06/2025.
//

import Foundation

class SecurityRepositoryImpl: SecurityRepository {
    init(localDatasource: SecurityLocalDatasource, remoteDatasource: SecurityRemoteDatasource) {
        self.localDatasource = localDatasource
        self.remoteDatasource = remoteDatasource
    }
    
    let localDatasource: SecurityLocalDatasource
    let remoteDatasource: SecurityRemoteDatasource
    
    func checkSessionExists() -> Result<User, Error> {
        localDatasource.fetchUserSession().map { $0.toEntity }
    }
    
    func signup(email: String, password: String) async -> Result<User, Error> {
        let result = await remoteDatasource.signup(email: email, password: password)
        switch result {
        case .success(let user):
            _ = try? localDatasource.saveUserSession(user: UserDTO.fromEntity(user))
            return .success(user)
        case .failure(let failure):
            return .failure(failure)
        }
    }
    
    func login(email: String, password: String) async -> Result<User, Error> {
        let result = await remoteDatasource.login(email: email, password: password)
        switch result {
        case .success(let user):
            do {
                try localDatasource.saveUserSession(user: UserDTO.fromEntity(user))
                return .success(user)
            } catch {
                DefaultLogger.log(self, "Error saving user session: \(error)")
                return .failure(error)
            }
        case .failure(let failure):
            return .failure(failure)
        }
    }
    
    func logout() {
        try? remoteDatasource.logout()
        try? localDatasource.clearUserSession()
    }
}
