//
//  ProductRepository.swift
//  ECommerceApp
//
//  Created by Ademola Fadumo on 21/06/2025.
//

import Foundation
import RxSwift

protocol ProductRepository {
    func getProducts() -> Observable<[Product]>
    func storeProduct(product: Product) async -> Result<Void, Error>
}
