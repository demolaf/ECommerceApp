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
        
        let request = CartMO.fetchRequest()
        request.sortDescriptors = []
        getCartObserver = try? FetchedResultsControllerObserver(fetchRequest: request, context: moc)
    }
    
    private let moc: NSManagedObjectContext
    private var getCartObserver: FetchedResultsControllerObserver<CartMO>?
    
    func checkIfProductInCart(_ productId: String) -> Result<ProductDTO, Error> {
        checkIfProductInCartDB(productId).map(ProductDTO.fromMO)
    }
    
    func getCart() -> Observable<Result<CartDTO, Error>> {
        guard let getCartObserver else { return Observable.just(.failure(Failure.notFoundInDatabase)) }
        
        return getCartObserver.asObservable()
            .map { cartList in
                if let cart = cartList.first {
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
