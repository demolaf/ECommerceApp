//
//  AuthCoordinator.swift
//  ECommerceApp
//
//  Created by Ademola Fadumo on 20/06/2025.
//

import UIKit

class AuthCoordinator: Coordinator {
    override func start() {
        let viewModel = LoginViewModel()
        let vc = LoginViewController(viewModel: viewModel)
        router.push(vc)
    }

    func navigateToHome() {
        let coordinator = MainCoordinator(router: Router(navigationController: UINavigationController()))
        coordinator.start()
    }
}
