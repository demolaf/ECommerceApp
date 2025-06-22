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
    
    func getProducts() -> Observable<Result<[ProductDTO], Error>> {
        Observable.create {[weak self] observer in
            guard let self else {
                return Disposables.create()
            }
            
            let listener = firestore.collection("products").addSnapshotListener { snapshots, error in
                guard let snapshots else {
                    print("Error fetching document: \(String(describing: error))")
                    if let error {
                        return observer.onNext(.failure(error))
                    }
                    return observer.onNext(.failure(Failure.getDocument))
                }
                
                let products = snapshots.documents.compactMap { try? $0.data(as: ProductDTO.self) }
                observer.onNext(.success(products))
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
    
    func getOrders() -> RxSwift.Observable<Result<[OrderDTO], any Error>> {
        Observable.create {[weak self] observer in
            guard let self else {
                return Disposables.create()
            }
            
            let listener = firestore.collection("orders").addSnapshotListener { snapshots, error in
                guard let snapshots else {
                    print("Error fetching document: \(String(describing: error))")
                    if let error {
                        return observer.onNext(.failure(error))
                    }
                    return observer.onNext(.failure(Failure.getDocument))
                }
                
                let orders = snapshots.documents.compactMap { try? $0.data(as: OrderDTO.self) }
                observer.onNext(.success(orders))
            }
            
            return Disposables.create {
                listener.remove()
            }
        }
    }
    
    func placeOrder(order: OrderDTO) async -> Result<Void, any Error> {
        do {
            let data = try JSONEncoder().encode(order)
            
            guard let body = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                return .failure(Failure.createDocument)
            }
            
            let docRef =  firestore.collection("orders").document(order.uid)
            try await docRef.setData(body)
            print("Document added with ID: \(docRef.documentID)")
            return .success(())
        } catch {
            debugPrint("Error \(error)")
            return .failure(error)
        }
    }
}
