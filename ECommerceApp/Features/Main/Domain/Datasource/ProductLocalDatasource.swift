//
//  ProductLocalDatasource.swift
//  ECommerceApp
//
//  Created by Ademola Fadumo on 21/06/2025.
//

import Foundation
import RxSwift

protocol ProductLocalDatasource {
    func getProducts() -> Result<[ProductDTO], Error>
    func updateProducts(_ products: [ProductDTO]) -> Result<Void, Error>
    func clearProducts() -> Result<Void, Error>
    func getOrders() -> Result<[OrderDTO], Error>
    func updateOrders(_ orders: [OrderDTO]) -> Result<Void, Error>
    func clearOrders() -> Result<Void, Error>
    func checkIfProductInCart(_ productId: String) -> Result<ProductDTO, Error>
    func getCart() -> Observable<Result<CartDTO, Error>>
    func addToCart(_ product: ProductDTO) -> Result<Void, Error>
    func removeFromCart(_ productId: String) -> Result<Void, Error>
    func clearCart() -> Result<Void, Error>
}
