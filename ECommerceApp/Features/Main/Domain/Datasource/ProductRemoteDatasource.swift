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
    func getOrders() -> Observable<Result<[OrderDTO], Error>>
    func placeOrder(order: OrderDTO) async -> Result<Void, Error>
}
