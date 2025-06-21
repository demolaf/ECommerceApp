//
//  MainCoordinator.swift
//  ECommerceApp
//
//  Created by Ademola Fadumo on 20/06/2025.
//

import UIKit

class MainCoordinator: Coordinator {
    override func start() {
        navigateToHome()
    }
    
    func navigateToHome() {
        let vc = HomeViewController()
        vc.coordinator = self
        router.push(vc)
    }
    
    func navigateToDetail() {
        let vc = DetailViewController()
        vc.coordinator = self
        router.push(vc)
    }
    
    func navigateToLogin() {
        let coordinator = AuthCoordinator(router: Router(navigationController: UINavigationController()))
        coordinator.parentCoordinator = self
        addChild(coordinator)
        coordinator.start()
    }
}
