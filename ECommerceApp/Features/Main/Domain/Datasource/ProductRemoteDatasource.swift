//
//  ProductRemoteDatasource.swift
//  ECommerceApp
//
//  Created by Ademola Fadumo on 21/06/2025.
//

import Foundation
import RxSwift

protocol ProductRemoteDatasource {
    func getProducts() -> Observable<Result<[ProductDTO], Error>>
    func storeProduct(product: ProductDTO) async -> Result<Void, Error>
    func getOrders(userId: String) -> Observable<Result<[OrderDTO], Error>>
    func placeOrder(order: OrderDTO) async -> Result<OrderDTO, Error>
    func cancelOrder(orderId: String) async -> Result<Void, Error>
}
