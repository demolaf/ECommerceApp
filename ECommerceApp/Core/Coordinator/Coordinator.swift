//
//  Coordinator.swift
//  ECommerceApp
//
//  Created by Ademola Fadumo on 20/06/2025.
//

import UIKit

@MainActor
open class Coordinator: NSObject, Coordinatable {
    public var router: Router
    public var parentCoordinator: Coordinatable?
    public var childCoordinators: [Coordinatable] = []
    
    public init(router: Router) {
        self.router = router
        super.init()
    }
    
    open func start() {
        fatalError("Start method must be implemented by concrete coordinator")
    }
    
    public func toPresentable() -> UIViewController {
        router.toPresentable()
    }
    
    deinit {
        DefaultLogger.log(self, functionName: "deinit", "Coordinator deinitializing")
    }
}
