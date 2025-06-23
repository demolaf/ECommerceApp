//
//  ProductRepositoryImpl.swift
//  ECommerceApp
//
//  Created by Ademola Fadumo on 21/06/2025.
//

import Foundation
import RxSwift

class ProductRepositoryImpl: ProductRepository {
    init(localDatasource: ProductLocalDatasource, remoteDatasource: ProductRemoteDatasource) {
        self.localDatasource = localDatasource
        self.remoteDatasource = remoteDatasource
    }
    
    let localDatasource: ProductLocalDatasource
    let remoteDatasource: ProductRemoteDatasource
    
    func getProducts() -> Observable<Result<[Product], Error>> {
        Observable.combineLatest(remoteDatasource.getProducts(), localDatasource.getCart())
            .map { productsResult, cartResult in
                switch (productsResult, cartResult) {
                case let (.success(products), .success(cart)):
                    let updatedProducts = products.map { product -> Product in
                        var updated = product.toEntity
                        updated.inCart = cart.products.contains(where: { $0.uid == product.uid })
                        return updated
                    }
                    return .success(updatedProducts)

                case let (.failure(error), _):
                    return .failure(error)

                case let (_, .failure(error)):
                    return .failure(error)
                }
            }
    }
    
    func storeProduct(product: Product) async -> Result<Void, Error> {
        await remoteDatasource.storeProduct(product: ProductDTO.fromEntity(product))
    }
    
    func getOrders(userId: String) -> Observable<Result<[Order], Error>> {
        remoteDatasource.getOrders(userId: userId).map { result in
            result.map { $0.map(\.toEntity) }
        }
    }
    
    func placeOrder(userId: String, cart: Cart) async -> Result<Order, Error> {
        let result = await remoteDatasource.placeOrder(
            order: OrderDTO(
                uid: UUID().uuidString,
                userId: userId,
                products: cart.products.map(ProductDTO.fromEntity),
                createdAt: Date.init().toISO8601String()
            ))
        switch result {
        case .success(let order):
            _ = localDatasource.clearCart()
            return .success(order.toEntity)
        case .failure(let failure):
            return .failure(failure)
        }
    }
    
    func checkIfProductInCart(_ productId: UUID) -> Result<Product, Error> {
        localDatasource.checkIfProductInCart(productId.uuidString).map(\.toEntity)
    }
    
    func getCart() -> Observable<Result<Cart, Error>> {
        localDatasource.getCart().map { $0.map(\.toEntity) }
    }
    
    func addToCart(_ product: Product) -> Result<Void, Error> {
        localDatasource.addToCart(ProductDTO.fromEntity(product))
    }
    
    func removeFromCart(_ productId: UUID) -> Result<Void, Error> {
        localDatasource.removeFromCart(productId.uuidString)
    }
    
    func clearCart() -> Result<Void, Error> {
        localDatasource.clearCart()
    }
}
