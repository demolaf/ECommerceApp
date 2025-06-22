//
//  ProductRepository.swift
//  ECommerceApp
//
//  Created by Ademola Fadumo on 21/06/2025.
//

import Foundation
import RxSwift

protocol ProductRepository {
    func getProducts() -> Observable<Result<[Product], Error>>
    func storeProduct(product: Product) async -> Result<Void, Error>
    func getOrders() -> Observable<Result<[Order], Error>>
    func placeOrder(userId: String, cart: Cart) async -> Result<Void, Error>
    func checkIfProductInCart(_ productId: UUID) -> Result<Product, Error>
    func getCart() -> Result<Cart, Error>
    func addToCart(_ product: Product) -> Result<Void, Error>
    func removeFromCart(_ productId: UUID) -> Result<Void, Error>
}
