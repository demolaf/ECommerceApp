//
//  CartMO+CoreDataProperties.swift
//  ECommerceApp
//
//  Created by Ademola Fadumo on 22/06/2025.
//
//

public import Foundation
public import CoreData


public typealias CartMOCoreDataPropertiesSet = NSSet

extension CartMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CartMO> {
        return NSFetchRequest<CartMO>(entityName: "Cart")
    }

    @NSManaged public var cartId: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var products: NSSet?

}

// MARK: Generated accessors for products
extension CartMO {

    @objc(addProductsObject:)
    @NSManaged public func addToProducts(_ value: ProductMO)

    @objc(removeProductsObject:)
    @NSManaged public func removeFromProducts(_ value: ProductMO)

    @objc(addProducts:)
    @NSManaged public func addToProducts(_ values: NSSet)

    @objc(removeProducts:)
    @NSManaged public func removeFromProducts(_ values: NSSet)

}

extension CartMO : Identifiable {

}
