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
            
            let listener = firestore.collection(FirebaseCollections.products.collectionPath).addSnapshotListener { snapshots, error in
                guard let snapshots else {
                    DefaultLogger.log(self, "Error fetching document: \(String(describing: error))")
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
            
            let docRef =  firestore.collection(FirebaseCollections.products.collectionPath).document(product.uid)
            try await docRef.setData(body)
            DefaultLogger.log(self, "Document added with ID: \(docRef.documentID)")
            return .success(())
        } catch {
            DefaultLogger.log(self, "Error \(error)")
            return .failure(error)
        }
    }
    
    func getOrders(userId: String) -> Observable<Result<[OrderDTO], Error>> {
        Observable.create {[weak self] observer in
            guard let self else {
                return Disposables.create()
            }
            
            let listener = firestore.collection(FirebaseCollections.orders.collectionPath).whereField("userId", isEqualTo: userId).addSnapshotListener { snapshots, error in
                guard let snapshots else {
                    DefaultLogger.log(self, "Error fetching document: \(String(describing: error))")
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
    
    func placeOrder(order: OrderDTO) async -> Result<OrderDTO, Error> {
        do {
            let data = try JSONEncoder().encode(order)
            
            guard let body = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                return .failure(Failure.createDocument)
            }
            
            let docRef =  firestore.collection(FirebaseCollections.orders.collectionPath).document(order.uid)
            try await docRef.setData(body)
            DefaultLogger.log(self, "Document added with ID: \(docRef.documentID)")
            return .success(order)
        } catch {
            DefaultLogger.log(self, "Error \(error)")
            return .failure(error)
        }
    }
    
    func cancelOrder(orderId: String) async -> Result<Void, Error> {
        do {
            let docRef =  firestore.collection(FirebaseCollections.orders.collectionPath).document(orderId)
            try await docRef.delete()
            return .success(())
        } catch {
            DefaultLogger.log(self, "Error \(error)")
            return .failure(error)
        }
    }
}
