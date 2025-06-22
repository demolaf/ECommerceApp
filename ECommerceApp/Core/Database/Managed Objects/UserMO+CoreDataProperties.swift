//
//  UserMO+CoreDataProperties.swift
//  ECommerceApp
//
//  Created by Ademola Fadumo on 21/06/2025.
//
//

public import Foundation
public import CoreData


public typealias UserMOCoreDataPropertiesSet = NSSet

extension UserMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserMO> {
        return NSFetchRequest<UserMO>(entityName: "User")
    }

    @NSManaged public var displayName: String?
    @NSManaged public var email: String?
    @NSManaged public var uid: String?

}

extension UserMO : Identifiable {

}
