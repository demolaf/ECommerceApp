//
//  DependencyContainer.swift
//  ECommerceApp
//
//  Created by Ademola Fadumo on 21/06/2025.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import CoreData

@MainActor class DependencyContainer {
    private init() {
        // Service
        firebaseAuth = Auth.auth()
        firestore = Firestore.firestore()
        viewMOC = ModelContainer.shared.persistentContainer.viewContext
        backgroundMOC = ModelContainer.shared.persistentContainer.newBackgroundContext()
        backgroundMOC.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
        
        // Datasource
        securityLocalDatasource = SecurityLocalDatasourceImpl(moc: viewMOC)
        securityRemoteDatasource = SecurityRemoteDatasourceImpl(firebaseAuth: firebaseAuth)
        
        productLocalDatasource = ProductLocalDatasourceImpl(moc: viewMOC)
        productRemoteDatasource = ProductRemoteDatasourceImpl(firestore: firestore)
        
        // Repository
        securityRepository = SecurityRepositoryImpl(localDatasource: securityLocalDatasource, remoteDatasource: securityRemoteDatasource)
        productRepository = ProductRepositoryImpl(localDatasource: productLocalDatasource, remoteDatasource: productRemoteDatasource)
    }
    
    @MainActor static let shared = DependencyContainer()
    
    // MARK: - Services
    private let firebaseAuth: Auth
    private let firestore: Firestore
    private let viewMOC: NSManagedObjectContext
    private let backgroundMOC: NSManagedObjectContext
    
    // MARK: - Datasources
    private let securityLocalDatasource: SecurityLocalDatasource
    private let securityRemoteDatasource: SecurityRemoteDatasource
    
    private let productLocalDatasource: ProductLocalDatasource
    private let productRemoteDatasource: ProductRemoteDatasource
    
    // MARK: - Repositories
    let securityRepository: SecurityRepository
    let productRepository: ProductRepository
}
