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
        let viewModel = HomeViewModel(securityRepository: DependencyContainer.shared.securityRepository, productRepository: DependencyContainer.shared.productRepository)
        let vc = HomeViewController(viewModel: viewModel)
        vc.navigationItem.hidesBackButton = true
        vc.coordinator = self
        router.push(vc)
    }
    
    func navigateToDetail() {
        let vc = OrdersViewController()
        vc.coordinator = self
        router.push(vc)
    }
    
    func navigateToLogin() {
        let coordinator = AuthCoordinator(router: router)
        coordinator.parentCoordinator = self
        addChild(coordinator)
        coordinator.navigateToLogin()
    }
    
    func navigateToAddProduct() {
        let viewModel = AddProductViewModel(productRepository: DependencyContainer.shared.productRepository)
        let vc = AddProductViewController(viewModel: viewModel)
        vc.coordinator = self
        router.push(vc)
    }
}
