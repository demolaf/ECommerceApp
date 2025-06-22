//
//  ProductRemoteDatasourceImpl.swift
//  ECommerceApp
//
//  Created by Ademola Fadumo on 21/06/2025.
//

import Foundation
import RxSwift
import FirebaseFirestore

class ProductRemoteDatasourceImpl: ProductRemoteDatasource {
    init(firestore: Firestore) {
        self.firestore = firestore
    }
    
    let firestore: Firestore
    
    func getProducts() -> Observable<[ProductDTO]> {
        Observable.create {[weak self] observer in
            guard let self = self else {
                return Disposables.create()
            }
            
            let listener = firestore.collection("products").addSnapshotListener { snapshots, error in
                guard let snapshots = snapshots else {
                    print("Error fetching document: \(String(describing: error))")
                    return
                }
                let products = snapshots.documents.compactMap { try? $0.data(as: ProductDTO.self) }
                observer.onNext(products)
            }
            
            return Disposables.create {
                listener.remove()
            }
        }
    }
    
    func storeProduct(product: ProductDTO) async -> Result<Void, Error> {
        do {
            let data = try JSONEncoder().encode(product)
            
            guard let body = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                return .failure(Failure.createDocument)
            }
            
            let docRef =  firestore.collection("products").document(product.uid)
            try await docRef.setData(body)
            print("Document added with ID: \(docRef.documentID)")
            return .success(())
        } catch {
            debugPrint("Error \(error)")
            return .failure(error)
        }
    }
}
