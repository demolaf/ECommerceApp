//
//  ProductLocalDatasourceImpl.swift
//  ECommerceApp
//
//  Created by Ademola Fadumo on 21/06/2025.
//

import Foundation
import CoreData
import RxSwift

class ProductLocalDatasourceImpl: ProductLocalDatasource {
    init(moc: NSManagedObjectContext) {
        self.moc = moc
    }
    
    private let moc: NSManagedObjectContext
    private lazy var getCartObserver: FetchedResultsControllerObserver<CartMO>? = {
        let request = CartMO.fetchRequest()
        request.sortDescriptors = []
        return try? FetchedResultsControllerObserver(fetchRequest: request, context: moc)
    }()
    
//    private lazy var getProductsObserver: FetchedResultsControllerObserver<ProductMO>? = {
//        let request = ProductMO.fetchRequest()
//        request.sortDescriptors = []
//        return try? FetchedResultsControllerObserver(fetchRequest: request, context: moc)
//    }()
//    
//    private lazy var getOrdersObserver: FetchedResultsControllerObserver<OrderMO>? = {
//        let request = OrderMO.fetchRequest()
//        request.sortDescriptors = []
//        return try? FetchedResultsControllerObserver(fetchRequest: request, context: moc)
//    }()
    
    func getProducts() -> Result<[ProductDTO], Error> {
        do {
            let products = try moc.fetch(ProductMO.fetchRequest())
            return .success(products.map(ProductDTO.fromMO))
        } catch {
            return .failure(error)
        }
    }
    
    func updateProducts(_ products: [ProductDTO]) -> Result<Void, Error> {
        do {
            // Clear existing products first
            let existingProducts = try moc.fetch(ProductMO.fetchRequest())
            existingProducts.forEach { moc.delete($0) }
            
            // Add new products
            products.forEach { productDTO in
                let productMO = ProductMO(context: moc)
                productMO.name = productDTO.name
                productMO.photoUrl = productDTO.photoUrl
                productMO.uid = productDTO.uid
                productMO.price = productDTO.price
            }
            
            try moc.save()
            return .success(())
        } catch {
            return .failure(error)
        }
    }
    
    func clearProducts() -> Result<Void, Error> {
        do {
            let existingProducts = try moc.fetch(ProductMO.fetchRequest())
            existingProducts.forEach { moc.delete($0) }
            
            try moc.save()
            return .success(())
        } catch {
            return .failure(error)
        }
    }
    
    func getOrders() -> Result<[OrderDTO], Error> {
        do {
            let orders = try moc.fetch(OrderMO.fetchRequest())
            return .success(orders.map(OrderDTO.fromMO))
        } catch {
            return .failure(error)
        }
    }
    
    func updateOrders(_ orders: [OrderDTO]) -> Result<Void, Error> {
        do {
            // Clear existing orders first
            let existingOrders = try moc.fetch(OrderMO.fetchRequest())
            existingOrders.forEach { moc.delete($0) }
            
            // Add new orders
            orders.forEach { orderDTO in
                let orderMO = OrderMO(context: moc)
                orderMO.uid = orderDTO.uid
                orderMO.userId = orderDTO.userId
                orderMO.status = orderDTO.status
                orderMO.createdAt = orderDTO.createdAt.iso8601ToDate()
                
                // Add products to order if they exist
                orderDTO.products.forEach { productDTO in
                    let productMO = ProductMO(context: moc)
                    productMO.name = productDTO.name
                    productMO.photoUrl = productDTO.photoUrl
                    productMO.uid = productDTO.uid
                    productMO.price = productDTO.price
                    orderMO.addToProducts(productMO)
                }
            }
            
            try moc.save()
            return .success(())
        } catch {
            return .failure(error)
        }
    }
    
    func clearOrders() -> Result<Void, Error> {
        do {
            let existingOrders = try moc.fetch(OrderMO.fetchRequest())
            existingOrders.forEach { moc.delete($0) }
            
            try moc.save()
            return .success(())
        } catch {
            return .failure(error)
        }
    }
    
    func checkIfProductInCart(_ productId: String) -> Result<ProductDTO, Error> {
        checkIfProductInCartDB(productId).map(ProductDTO.fromMO)
    }
    
    func getCart() -> Observable<Result<CartDTO, Error>> {
        guard let getCartObserver else {
            return Observable.just(.failure(Failure.notFoundInDatabase))
        }
        
        return getCartObserver.asObservable()
            .map { carts in
                if let cart = carts.first {
                    return .success(CartDTO.fromMO(cart))
                } else {
                    // Create new CartMO and emit it
                    let cartMO = CartMO(context: self.moc)
                    cartMO.cartId = UUID().uuidString
                    cartMO.createdAt = .init()
                    
                    do {
                        try self.moc.save()
                        return .success(CartDTO.fromMO(cartMO))
                    } catch {
                        return .failure(error)
                    }
                }
            }
    }
    
    func addToCart(_ product: ProductDTO) -> Result<Void, Error> {
        let newProduct = ProductMO(context: moc)
        newProduct.name = product.name
        newProduct.photoUrl = product.photoUrl
        newProduct.uid = product.uid
        newProduct.price = product.price
        
        do {
            if let cart = try moc.fetch(CartMO.fetchRequest()).first {
                cart.addToProducts(newProduct)
            } else {
                let cartMO = CartMO(context: moc)
                cartMO.cartId = UUID().uuidString
                cartMO.createdAt = .init()
                cartMO.addToProducts(newProduct)
            }
            
            try moc.save()
            return .success(())
        } catch {
            return .failure(error)
        }
    }
    
    func removeFromCart(_ productId: String) -> Result<Void, Error> {
        do {
            guard let cart = try moc.fetch(CartMO.fetchRequest()).first else {
                return .failure(Failure.notFoundInDatabase)
            }
            
            let result = checkIfProductInCartDB(productId)
            
            switch result {
            case .success(let existingProduct):
                cart.removeFromProducts(existingProduct)
            case .failure(let failure):
                return .failure(failure)
            }
            
            try moc.save()
            return .success(())
        } catch {
            return .failure(error)
        }
    }
    
    func clearCart() -> Result<Void, any Error> {
        do {
            guard let existingCart = try moc.fetch(CartMO.fetchRequest()).first else {
                return .failure(Failure.notFoundInDatabase)
            }
            
            guard let products = existingCart.products as? Set<ProductMO> else {
                return .failure(Failure.notFoundInDatabase)
            }
            
            products.forEach { product in
                moc.delete(product)
            }
            
            try moc.save()
            return .success(())
        } catch {
            return .failure(error)
        }
    }
    
    private func checkIfProductInCartDB(_ productId: String) -> Result<ProductMO, Error> {
        do {
            guard let cart = try moc.fetch(CartMO.fetchRequest()).first else {
                return .failure(Failure.notFoundInDatabase)
            }
            
            guard let products = cart.products as? Set<ProductMO> else {
                return .failure(Failure.notFoundInDatabase)
            }
            
            guard let existingProduct = products.first(where: { $0.uid == productId }) else {
                return .failure(Failure.notFoundInDatabase)
            }
            
            return .success(existingProduct)
        } catch {
            return .failure(error)
        }
    }
}
