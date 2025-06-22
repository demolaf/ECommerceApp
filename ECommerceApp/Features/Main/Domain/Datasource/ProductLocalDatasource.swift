//
//  ProductLocalDatasource.swift
//  ECommerceApp
//
//  Created by Ademola Fadumo on 21/06/2025.
//

import Foundation
import RxSwift

protocol ProductLocalDatasource {
    func checkIfProductInCart(_ productId: String) -> Result<ProductDTO, Error>
    func getCart() -> Observable<Result<CartDTO, Error>>
    func addToCart(_ product: ProductDTO) -> Result<Void, Error>
    func removeFromCart(_ productId: String) -> Result<Void, Error>
}
