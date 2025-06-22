//
//  ProductMO+CoreDataProperties.swift
//  ECommerceApp
//
//  Created by Ademola Fadumo on 21/06/2025.
//
//

public import Foundation
public import CoreData


public typealias ProductMOCoreDataPropertiesSet = NSSet

extension ProductMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ProductMO> {
        return NSFetchRequest<ProductMO>(entityName: "Product")
    }

    @NSManaged public var uid: String?
    @NSManaged public var name: String?
    @NSManaged public var photoUrl: String?
    @NSManaged public var price: Double

}

extension ProductMO : Identifiable {

}
