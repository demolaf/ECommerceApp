//
//  ProductRemoteDatasource.swift
//  ECommerceApp
//
//  Created by Ademola Fadumo on 21/06/2025.
//

import Foundation
import RxSwift

protocol ProductRemoteDatasource {
    func getProducts() -> Observable<[ProductDTO]>
    func storeProduct(product: ProductDTO) async -> Result<Void, Error>
}
