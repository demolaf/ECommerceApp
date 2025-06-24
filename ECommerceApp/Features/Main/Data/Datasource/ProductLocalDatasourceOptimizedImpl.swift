////
////  ProductLocalDatasourceOptimizedImpl.swift
////  ECommerceApp
////
////  Created by Ademola Fadumo on 21/06/2025.
////
//
//import Foundation
//import CoreData
//import RxSwift
//
//class ProductLocalDatasourceOptimizedImpl: ProductLocalDatasourceOptimized {
//    init(moc: NSManagedObjectContext, backgroundMOC: NSManagedObjectContext) {
//        self.moc = moc
//        self.backgroundContext = backgroundMOC
//    }
//    
//    private let moc: NSManagedObjectContext
//    private let backgroundContext: NSManagedObjectContext
//    
//    private lazy var getCartObserver: FetchedResultsControllerObserver<CartMO>? = {
//        let request = CartMO.fetchRequest()
//        request.sortDescriptors = []
//        return try? FetchedResultsControllerObserver(fetchRequest: request, context: moc)
//    }()
//    
//    private lazy var getProductsObserver: FetchedResultsControllerObserver<ProductMO>? = {
//        let request = ProductMO.fetchRequest()
//        request.sortDescriptors = []
//        return try? FetchedResultsControllerObserver(fetchRequest: request, context: moc)
//    }()
//    
//    private lazy var getOrdersObserver: FetchedResultsControllerObserver<OrderMO>? = {
//        let request = OrderMO.fetchRequest()
//        request.sortDescriptors = []
//        return try? FetchedResultsControllerObserver(fetchRequest: request, context: moc)
//    }()
//    
//    func getProducts() -> Observable<Result<[ProductDTO], Error>> {
//        guard let getProductsObserver else {
//            return Observable.just(.failure(Failure.notFoundInDatabase))
//        }
//        return getProductsObserver.asObservable().map { .success($0.map(ProductDTO.fromMO)) }
//    }
//    
//    func updateProducts(_ products: [ProductDTO]) -> Result<Void, Error> {
//        // For large datasets, use background context
//        if products.count > 100 {
//            return updateProductsInBackground(products)
//        }
//        
//        return updateProductsInMainContext(products)
//    }
//    
//    private func updateProductsInMainContext(_ products: [ProductDTO]) -> Result<Void, Error> {
//        do {
//            // Use batch delete for better performance
//            let deleteRequest = NSBatchDeleteRequest(fetchRequest: ProductMO.fetchRequest())
//            deleteRequest.resultType = .resultTypeObjectIDs
//            let deleteResult = try moc.execute(deleteRequest) as? NSBatchDeleteResult
//            
//            // Add new products
//            products.forEach { productDTO in
//                let productMO = ProductMO(context: moc)
//                productMO.name = productDTO.name
//                productMO.photoUrl = productDTO.photoUrl
//                productMO.uid = productDTO.uid
//                productMO.price = productDTO.price
//            }
//            
//            try moc.save()
//            
//            // Update UI context if batch delete was used
//            if let objectIDs = deleteResult?.result as? [NSManagedObjectID] {
//                let changes = [NSDeletedObjectsKey: objectIDs]
//                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [moc])
//            }
//            
//            return .success(())
//        } catch {
//            return .failure(error)
//        }
//    }
//    
//    private func updateProductsInBackground(_ products: [ProductDTO]) -> Result<Void, Error> {
//        let semaphore = DispatchSemaphore(value: 0)
//        var result: Result<Void, Error> = .failure(Failure.databaseError("Unknown error"))
//        
//        backgroundContext.perform { [weak self] in
//            guard let self else { return }
//            do {
//                // Use batch delete for better performance
//                let deleteRequest = NSBatchDeleteRequest(fetchRequest: ProductMO.fetchRequest())
//                deleteRequest.resultType = .resultTypeObjectIDs
//                let deleteResult = try backgroundContext.execute(deleteRequest) as? NSBatchDeleteResult
//                
//                // Add new products in batches
//                let batchSize = 50
//                for i in stride(from: 0, to: products.count, by: batchSize) {
//                    let endIndex = min(i + batchSize, products.count)
//                    let batch = Array(products[i..<endIndex])
//                    
//                    batch.forEach { productDTO in
//                        let productMO = ProductMO(context: backgroundContext)
//                        productMO.name = productDTO.name
//                        productMO.photoUrl = productDTO.photoUrl
//                        productMO.uid = productDTO.uid
//                        productMO.price = productDTO.price
//                    }
//                    
//                    try backgroundContext.save()
//                }
//                
//                // Update main context
//                if let objectIDs = deleteResult?.result as? [NSManagedObjectID] {
//                    let changes = [NSDeletedObjectsKey: objectIDs]
//                    NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [self.moc])
//                }
//                
//                result = .success(())
//            } catch {
//                result = .failure(error)
//            }
//            
//            semaphore.signal()
//        }
//        
//        semaphore.wait()
//        return result
//    }
//    
//    func clearProducts() -> Result<Void, Error> {
//        do {
//            // Use batch delete for better performance
//            let deleteRequest = NSBatchDeleteRequest(fetchRequest: ProductMO.fetchRequest())
//            deleteRequest.resultType = .resultTypeObjectIDs
//            let deleteResult = try moc.execute(deleteRequest) as? NSBatchDeleteResult
//            
//            try moc.save()
//            
//            // Update UI context
//            if let objectIDs = deleteResult?.result as? [NSManagedObjectID] {
//                let changes = [NSDeletedObjectsKey: objectIDs]
//                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [moc])
//            }
//            
//            return .success(())
//        } catch {
//            return .failure(error)
//        }
//    }
//    
//    func getOrders() -> Observable<Result<[OrderDTO], Error>> {
//        guard let getOrdersObserver else {
//            return Observable.just(.failure(Failure.notFoundInDatabase))
//        }
//        return getOrdersObserver.asObservable().map { .success($0.map(OrderDTO.fromMO)) }
//    }
//    
//    func updateOrders(_ orders: [OrderDTO]) -> Result<Void, Error> {
//        // For large datasets, use background context
//        if orders.count > 50 {
//            return updateOrdersInBackground(orders)
//        }
//        
//        return updateOrdersInMainContext(orders)
//    }
//    
//    private func updateOrdersInMainContext(_ orders: [OrderDTO]) -> Result<Void, Error> {
//        do {
//            // Use batch delete for better performance
//            let deleteRequest = NSBatchDeleteRequest(fetchRequest: OrderMO.fetchRequest())
//            deleteRequest.resultType = .resultTypeObjectIDs
//            let deleteResult = try moc.execute(deleteRequest) as? NSBatchDeleteResult
//            
//            // Add new orders
//            orders.forEach { orderDTO in
//                let orderMO = OrderMO(context: moc)
//                orderMO.uid = orderDTO.uid
//                orderMO.userId = orderDTO.userId
//                orderMO.status = orderDTO.status
//                orderMO.createdAt = orderDTO.createdAt.iso8601ToDate()
//                
//                // Add products to order if they exist
//                
//                orderDTO.products.forEach { productDTO in
//                    let productMO = ProductMO(context: moc)
//                    productMO.name = productDTO.name
//                    productMO.photoUrl = productDTO.photoUrl
//                    productMO.uid = productDTO.uid
//                    productMO.price = productDTO.price
//                    orderMO.addToProducts(productMO)
//                }
//                
//            }
//            
//            try moc.save()
//            
//            // Update UI context if batch delete was used
//            if let objectIDs = deleteResult?.result as? [NSManagedObjectID] {
//                let changes = [NSDeletedObjectsKey: objectIDs]
//                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [moc])
//            }
//            
//            return .success(())
//        } catch {
//            return .failure(error)
//        }
//    }
//    
//    private func updateOrdersInBackground(_ orders: [OrderDTO]) -> Result<Void, Error> {
//        let semaphore = DispatchSemaphore(value: 0)
//        var result: Result<Void, Error> = .failure(Failure.databaseError("Unknown error"))
//        
//        backgroundContext.perform { [weak self] in
//            guard let self else { return }
//            do {
//                // Use batch delete for better performance
//                let deleteRequest = NSBatchDeleteRequest(fetchRequest: OrderMO.fetchRequest())
//                deleteRequest.resultType = .resultTypeObjectIDs
//                let deleteResult = try backgroundContext.execute(deleteRequest) as? NSBatchDeleteResult
//                
//                // Add new orders in batches
//                let batchSize = 25
//                for i in stride(from: 0, to: orders.count, by: batchSize) {
//                    let endIndex = min(i + batchSize, orders.count)
//                    let batch = Array(orders[i..<endIndex])
//                    
//                    batch.forEach { orderDTO in
//                        let orderMO = OrderMO(context: backgroundContext)
//                        orderMO.uid = orderDTO.uid
//                        orderMO.userId = orderDTO.userId
//                        orderMO.status = orderDTO.status
//                        orderMO.createdAt = orderDTO.createdAt.iso8601ToDate()
//                        
//                        // Add products to order if they exist
//              
//                            orderDTO.products.forEach { productDTO in
//                                let productMO = ProductMO(context: backgroundContext)
//                                productMO.name = productDTO.name
//                                productMO.photoUrl = productDTO.photoUrl
//                                productMO.uid = productDTO.uid
//                                productMO.price = productDTO.price
//                                orderMO.addToProducts(productMO)
//                            }
//                    
//                    }
//                    
//                    try backgroundContext.save()
//                }
//                
//                // Update main context
//                if let objectIDs = deleteResult?.result as? [NSManagedObjectID] {
//                    let changes = [NSDeletedObjectsKey: objectIDs]
//                    NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [self.moc])
//                }
//                
//                result = .success(())
//            } catch {
//                result = .failure(error)
//            }
//            
//            semaphore.signal()
//        }
//        
//        semaphore.wait()
//        return result
//    }
//    
//    func clearOrders() -> Result<Void, Error> {
//        do {
//            // Use batch delete for better performance
//            let deleteRequest = NSBatchDeleteRequest(fetchRequest: OrderMO.fetchRequest())
//            deleteRequest.resultType = .resultTypeObjectIDs
//            let deleteResult = try moc.execute(deleteRequest) as? NSBatchDeleteResult
//            
//            try moc.save()
//            
//            // Update UI context
//            if let objectIDs = deleteResult?.result as? [NSManagedObjectID] {
//                let changes = [NSDeletedObjectsKey: objectIDs]
//                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [moc])
//            }
//            
//            return .success(())
//        } catch {
//            return .failure(error)
//        }
//    }
//    
//    func checkIfProductInCart(_ productId: String) -> Result<ProductDTO, Error> {
//        checkIfProductInCartDB(productId).map(ProductDTO.fromMO)
//    }
//    
//    func getCart() -> Observable<Result<CartDTO, Error>> {
//        guard let getCartObserver else {
//            return Observable.just(.failure(Failure.notFoundInDatabase))
//        }
//        
//        return getCartObserver.asObservable()
//            .map { carts in
//                if let cart = carts.first {
//                    return .success(CartDTO.fromMO(cart))
//                } else {
//                    // Create new CartMO and emit it
//                    let cartMO = CartMO(context: self.moc)
//                    cartMO.cartId = UUID().uuidString
//                    cartMO.createdAt = .init()
//                    
//                    do {
//                        try self.moc.save()
//                        return .success(CartDTO.fromMO(cartMO))
//                    } catch {
//                        return .failure(error)
//                    }
//                }
//            }
//    }
//    
//    func addToCart(_ product: ProductDTO) -> Result<Void, Error> {
//        let newProduct = ProductMO(context: moc)
//        newProduct.name = product.name
//        newProduct.photoUrl = product.photoUrl
//        newProduct.uid = product.uid
//        newProduct.price = product.price
//        
//        do {
//            if let cart = try moc.fetch(CartMO.fetchRequest()).first {
//                cart.addToProducts(newProduct)
//            } else {
//                let cartMO = CartMO(context: moc)
//                cartMO.cartId = UUID().uuidString
//                cartMO.createdAt = .init()
//                cartMO.addToProducts(newProduct)
//            }
//            
//            try moc.save()
//            return .success(())
//        } catch {
//            return .failure(error)
//        }
//    }
//    
//    func removeFromCart(_ productId: String) -> Result<Void, Error> {
//        do {
//            guard let cart = try moc.fetch(CartMO.fetchRequest()).first else {
//                return .failure(Failure.notFoundInDatabase)
//            }
//            
//            let result = checkIfProductInCartDB(productId)
//            
//            switch result {
//            case .success(let existingProduct):
//                cart.removeFromProducts(existingProduct)
//                moc.delete(existingProduct) // Explicitly delete the product
//            case .failure(let failure):
//                return .failure(failure)
//            }
//            
//            try moc.save()
//            return .success(())
//        } catch {
//            return .failure(error)
//        }
//    }
//    
//    func clearCart() -> Result<Void, any Error> {
//        do {
//            guard let existingCart = try moc.fetch(CartMO.fetchRequest()).first else {
//                return .failure(Failure.notFoundInDatabase)
//            }
//            
//            guard let products = existingCart.products as? Set<ProductMO> else {
//                return .failure(Failure.notFoundInDatabase)
//            }
//            
//            // Use batch delete for better performance if there are many products
//            if products.count > 20 {
//                let productIds = products.map { $0.objectID }
//                let deleteRequest = NSBatchDeleteRequest(objectIDs: productIds)
//                deleteRequest.resultType = .resultTypeObjectIDs
//                let deleteResult = try moc.execute(deleteRequest) as? NSBatchDeleteResult
//                
//                try moc.save()
//                
//                // Update UI context
//                if let objectIDs = deleteResult?.result as? [NSManagedObjectID] {
//                    let changes = [NSDeletedObjectsKey: objectIDs]
//                    NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [moc])
//                }
//            } else {
//                // For smaller sets, use individual deletes
//                products.forEach { product in
//                    moc.delete(product)
//                }
//                try moc.save()
//            }
//            
//            return .success(())
//        } catch {
//            return .failure(error)
//        }
//    }
//    
//    private func checkIfProductInCartDB(_ productId: String) -> Result<ProductMO, Error> {
//        do {
//            guard let cart = try moc.fetch(CartMO.fetchRequest()).first else {
//                return .failure(Failure.notFoundInDatabase)
//            }
//            
//            guard let products = cart.products as? Set<ProductMO> else {
//                return .failure(Failure.notFoundInDatabase)
//            }
//            
//            guard let existingProduct = products.first(where: { $0.uid == productId }) else {
//                return .failure(Failure.notFoundInDatabase)
//            }
//            
//            return .success(existingProduct)
//        } catch {
//            return .failure(error)
//        }
//    }
//    
//    // MARK: - Async Operations
//    
//    func updateProductsAsync(_ products: [ProductDTO]) -> Observable<Result<Void, Error>> {
//        return Observable.create { [weak self] observer in
//            guard let self = self else {
//                observer.onNext(.failure(Failure.databaseError("Self is nil")))
//                observer.onCompleted()
//                return Disposables.create()
//            }
//            
//            guard let backgroundContext = self.backgroundContext else {
//                observer.onNext(.failure(Failure.databaseError("Background context not available")))
//                observer.onCompleted()
//                return Disposables.create()
//            }
//            
//            backgroundContext.perform {
//                do {
//                    // Use batch delete for better performance
//                    let deleteRequest = NSBatchDeleteRequest(fetchRequest: ProductMO.fetchRequest())
//                    deleteRequest.resultType = .resultTypeObjectIDs
//                    let deleteResult = try backgroundContext.execute(deleteRequest) as? NSBatchDeleteResult
//                    
//                    // Add new products in batches
//                    let batchSize = 50
//                    for i in stride(from: 0, to: products.count, by: batchSize) {
//                        let endIndex = min(i + batchSize, products.count)
//                        let batch = Array(products[i..<endIndex])
//                        
//                        batch.forEach { productDTO in
//                            let productMO = ProductMO(context: backgroundContext)
//                            productMO.name = productDTO.name
//                            productMO.photoUrl = productDTO.photoUrl
//                            productMO.uid = productDTO.uid
//                            productMO.price = productDTO.price
//                        }
//                        
//                        try backgroundContext.save()
//                    }
//                    
//                    // Update main context
//                    if let objectIDs = deleteResult?.result as? [NSManagedObjectID] {
//                        let changes = [NSDeletedObjectsKey: objectIDs]
//                        NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [self.moc])
//                    }
//                    
//                    observer.onNext(.success(()))
//                    observer.onCompleted()
//                } catch {
//                    observer.onNext(.failure(error))
//                    observer.onCompleted()
//                }
//            }
//            
//            return Disposables.create()
//        }
//    }
//    
//    func clearProductsAsync() -> Observable<Result<Void, Error>> {
//        return Observable.create { [weak self] observer in
//            guard let self = self else {
//                observer.onNext(.failure(Failure.databaseError("Self is nil")))
//                observer.onCompleted()
//                return Disposables.create()
//            }
//            
//            guard let backgroundContext = self.backgroundContext else {
//                observer.onNext(.failure(Failure.databaseError("Background context not available")))
//                observer.onCompleted()
//                return Disposables.create()
//            }
//            
//            backgroundContext.perform {
//                do {
//                    // Use batch delete for better performance
//                    let deleteRequest = NSBatchDeleteRequest(fetchRequest: ProductMO.fetchRequest())
//                    deleteRequest.resultType = .resultTypeObjectIDs
//                    let deleteResult = try backgroundContext.execute(deleteRequest) as? NSBatchDeleteResult
//                    
//                    try backgroundContext.save()
//                    
//                    // Update main context
//                    if let objectIDs = deleteResult?.result as? [NSManagedObjectID] {
//                        let changes = [NSDeletedObjectsKey: objectIDs]
//                        NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [self.moc])
//                    }
//                    
//                    observer.onNext(.success(()))
//                    observer.onCompleted()
//                } catch {
//                    observer.onNext(.failure(error))
//                    observer.onCompleted()
//                }
//            }
//            
//            return Disposables.create()
//        }
//    }
//    
//    func updateOrdersAsync(_ orders: [OrderDTO]) -> Observable<Result<Void, Error>> {
//        return Observable.create { [weak self] observer in
//            guard let self = self else {
//                observer.onNext(.failure(Failure.databaseError("Self is nil")))
//                observer.onCompleted()
//                return Disposables.create()
//            }
//            
//            guard let backgroundContext = self.backgroundContext else {
//                observer.onNext(.failure(Failure.databaseError("Background context not available")))
//                observer.onCompleted()
//                return Disposables.create()
//            }
//            
//            backgroundContext.perform {
//                do {
//                    // Use batch delete for better performance
//                    let deleteRequest = NSBatchDeleteRequest(fetchRequest: OrderMO.fetchRequest())
//                    deleteRequest.resultType = .resultTypeObjectIDs
//                    let deleteResult = try backgroundContext.execute(deleteRequest) as? NSBatchDeleteResult
//                    
//                    // Add new orders in batches
//                    let batchSize = 25
//                    for i in stride(from: 0, to: orders.count, by: batchSize) {
//                        let endIndex = min(i + batchSize, orders.count)
//                        let batch = Array(orders[i..<endIndex])
//                        
//                        batch.forEach { orderDTO in
//                            let orderMO = OrderMO(context: backgroundContext)
//                            orderMO.orderId = orderDTO.orderId
//                            orderMO.totalAmount = orderDTO.totalAmount
//                            orderMO.status = orderDTO.status
//                            orderMO.createdAt = orderDTO.createdAt
//                            
//                            // Add products to order if they exist
//                            if let products = orderDTO.products {
//                                products.forEach { productDTO in
//                                    let productMO = ProductMO(context: backgroundContext)
//                                    productMO.name = productDTO.name
//                                    productMO.photoUrl = productDTO.photoUrl
//                                    productMO.uid = productDTO.uid
//                                    productMO.price = productDTO.price
//                                    orderMO.addToProducts(productMO)
//                                }
//                            }
//                        }
//                        
//                        try backgroundContext.save()
//                    }
//                    
//                    // Update main context
//                    if let objectIDs = deleteResult?.result as? [NSManagedObjectID] {
//                        let changes = [NSDeletedObjectsKey: objectIDs]
//                        NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [self.moc])
//                    }
//                    
//                    observer.onNext(.success(()))
//                    observer.onCompleted()
//                } catch {
//                    observer.onNext(.failure(error))
//                    observer.onCompleted()
//                }
//            }
//            
//            return Disposables.create()
//        }
//    }
//    
//    func clearOrdersAsync() -> Observable<Result<Void, Error>> {
//        return Observable.create { [weak self] observer in
//            guard let self = self else {
//                observer.onNext(.failure(Failure.databaseError("Self is nil")))
//                observer.onCompleted()
//                return Disposables.create()
//            }
//            
//            guard let backgroundContext = self.backgroundContext else {
//                observer.onNext(.failure(Failure.databaseError("Background context not available")))
//                observer.onCompleted()
//                return Disposables.create()
//            }
//            
//            backgroundContext.perform {
//                do {
//                    // Use batch delete for better performance
//                    let deleteRequest = NSBatchDeleteRequest(fetchRequest: OrderMO.fetchRequest())
//                    deleteRequest.resultType = .resultTypeObjectIDs
//                    let deleteResult = try backgroundContext.execute(deleteRequest) as? NSBatchDeleteResult
//                    
//                    try backgroundContext.save()
//                    
//                    // Update main context
//                    if let objectIDs = deleteResult?.result as? [NSManagedObjectID] {
//                        let changes = [NSDeletedObjectsKey: objectIDs]
//                        NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [self.moc])
//                    }
//                    
//                    observer.onNext(.success(()))
//                    observer.onCompleted()
//                } catch {
//                    observer.onNext(.failure(error))
//                    observer.onCompleted()
//                }
//            }
//            
//            return Disposables.create()
//        }
//    }
//    
//    func clearCartAsync() -> Observable<Result<Void, Error>> {
//        return Observable.create { [weak self] observer in
//            guard let self = self else {
//                observer.onNext(.failure(Failure.databaseError("Self is nil")))
//                observer.onCompleted()
//                return Disposables.create()
//            }
//            
//            guard let backgroundContext = self.backgroundContext else {
//                observer.onNext(.failure(Failure.databaseError("Background context not available")))
//                observer.onCompleted()
//                return Disposables.create()
//            }
//            
//            backgroundContext.perform {
//                do {
//                    guard let existingCart = try backgroundContext.fetch(CartMO.fetchRequest()).first else {
//                        observer.onNext(.failure(Failure.notFoundInDatabase))
//                        observer.onCompleted()
//                        return
//                    }
//                    
//                    guard let products = existingCart.products as? Set<ProductMO> else {
//                        observer.onNext(.failure(Failure.notFoundInDatabase))
//                        observer.onCompleted()
//                        return
//                    }
//                    
//                    // Use batch delete for better performance if there are many products
//                    if products.count > 20 {
//                        let productIds = products.map { $0.objectID }
//                        let deleteRequest = NSBatchDeleteRequest(objectIDs: productIds)
//                        deleteRequest.resultType = .resultTypeObjectIDs
//                        let deleteResult = try backgroundContext.execute(deleteRequest) as? NSBatchDeleteResult
//                        
//                        try backgroundContext.save()
//                        
//                        // Update main context
//                        if let objectIDs = deleteResult?.result as? [NSManagedObjectID] {
//                            let changes = [NSDeletedObjectsKey: objectIDs]
//                            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [self.moc])
//                        }
//                    } else {
//                        // For smaller sets, use individual deletes
//                        products.forEach { product in
//                            backgroundContext.delete(product)
//                        }
//                        try backgroundContext.save()
//                    }
//                    
//                    observer.onNext(.success(()))
//                    observer.onCompleted()
//                } catch {
//                    observer.onNext(.failure(error))
//                    observer.onCompleted()
//                }
//            }
//            
//            return Disposables.create()
//        }
//    }
//}
