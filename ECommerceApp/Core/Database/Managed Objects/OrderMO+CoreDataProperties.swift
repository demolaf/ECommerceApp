//
//  OrderMO+CoreDataProperties.swift
//  ECommerceApp
//
//  Created by Ademola Fadumo on 22/06/2025.
//
//

public import Foundation
public import CoreData


public typealias OrderMOCoreDataPropertiesSet = NSSet

extension OrderMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<OrderMO> {
        return NSFetchRequest<OrderMO>(entityName: "Order")
    }

    @NSManaged public var uid: String?
    @NSManaged public var status: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var userId: String?
    @NSManaged public var products: NSSet?

}

// MARK: Generated accessors for products
extension OrderMO {

    @objc(addProductsObject:)
    @NSManaged public func addToProducts(_ value: ProductMO)

    @objc(removeProductsObject:)
    @NSManaged public func removeFromProducts(_ value: ProductMO)

    @objc(addProducts:)
    @NSManaged public func addToProducts(_ values: NSSet)

    @objc(removeProducts:)
    @NSManaged public func removeFromProducts(_ values: NSSet)

}

extension OrderMO : Identifiable {

}
