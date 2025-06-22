//
//  SecurityLocalDatasourceImpl.swift
//  ECommerceApp
//
//  Created by Ademola Fadumo on 21/06/2025.
//

import Foundation
import CoreData

class SecurityLocalDatasourceImpl: SecurityLocalDatasource {
    init(moc: NSManagedObjectContext) {
        self.moc = moc
    }
    
    private let moc: NSManagedObjectContext
    
    func fetchUserSession() -> Result<UserDTO?, Error> {
        do {
            if let user = try moc.fetch(UserMO.fetchRequest()).first {
                return .success(UserDTO.fromMO(user))
            }
            return .success(nil)
        } catch {
            return .failure(error)
        }
    }
    
    @discardableResult func saveUserSession(user: UserDTO) throws -> UserDTO {
        let userMO = UserMO(context: moc)
        userMO.uid = user.uid
        userMO.email = user.email
        userMO.displayName = user.displayName
        try moc.save()
        return user
    }
    
    func clearUserSession() throws {
        if let existingUser = try moc.fetch(UserMO.fetchRequest()).first {
            moc.delete(existingUser)
            try moc.save()
        }
    }
}
