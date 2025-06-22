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
    
    func getProducts() -> Observable<[Product]> {
        return remoteDatasource.getProducts().map { $0.map { $0.toEntity() } }
    }
    
    func storeProduct(product: Product) async -> Result<Void, Error> {
        return await remoteDatasource.storeProduct(product: ProductDTO.fromEntity(product))
    }
}
