//
//  LaunchCoordinator.swift
//  ECommerceApp
//
//  Created by Ademola Fadumo on 20/06/2025.
//

import UIKit

final class LaunchCoordinator: Coordinator {
    override func start() {
        let coordinator = AuthCoordinator(router: router)
        coordinator.parentCoordinator = self
        addChild(coordinator)
        coordinator.start()
    }
    
    func navigateToHome() {
        let coordinator = MainCoordinator(router: router)
        coordinator.parentCoordinator = self
        addChild(coordinator)
        coordinator.start()
    }
}
