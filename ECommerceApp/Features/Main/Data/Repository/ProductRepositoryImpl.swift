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
        remoteDatasource.getProducts().map { [weak self] result in
            guard let self else { return result.map { _ in [] } }
            
            return result.map { products in
                products.map { data in
                    var product = data.toEntity
                    let cartResult = self.checkIfProductInCart(product.id)
                    if case .success = cartResult {
                        product.inCart = true
                    }
                    return product
                }
            }
        }
    }
    
    func storeProduct(product: Product) async -> Result<Void, Error> {
        await remoteDatasource.storeProduct(product: ProductDTO.fromEntity(product))
    }
    
    func getOrders() -> Observable<Result<[Order], Error>> {
        remoteDatasource.getOrders().map { result in
            result.map { $0.map(\.toEntity) }
        }
    }
    
    func placeOrder(userId: String, cart: Cart) async -> Result<Void, Error> {
        await remoteDatasource.placeOrder(
            order: OrderDTO(
                uid: UUID().uuidString,
                status: "",
                userId: userId,
                products: cart.products.map(ProductDTO.fromEntity),
                createdAt: .init()
            ))
    }
    
    func checkIfProductInCart(_ productId: UUID) -> Result<Product, Error> {
        localDatasource.checkIfProductInCart(productId.uuidString).map(\.toEntity)
    }
    
    func getCart() -> Result<Cart, Error> {
        localDatasource.getCart().map(\.toEntity)
    }
    
    func addToCart(_ product: Product) -> Result<Void, Error> {
        localDatasource.addToCart(ProductDTO.fromEntity(product))
    }
    
    func removeFromCart(_ productId: UUID) -> Result<Void, Error> {
        localDatasource.removeFromCart(productId.uuidString)
    }
}
