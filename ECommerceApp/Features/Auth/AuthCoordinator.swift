//
//  AuthCoordinator.swift
//  ECommerceApp
//
//  Created by Ademola Fadumo on 20/06/2025.
//

import UIKit

class AuthCoordinator: Coordinator {
    override func start() {
        navigateToLogin()
    }
    
    func navigateToLogin() {
        let viewModel = LoginViewModel()
        let vc = LoginViewController(viewModel: viewModel)
        vc.coordinator = self
        router.push(vc)
    }
    
    func navigateToSignup() {
        let viewModel = SignupViewModel()
        let vc = SignupViewController(viewModel: viewModel)
        vc.coordinator = self
        router.push(vc)
    }

    func navigateToHome() {
        let coordinator = MainCoordinator(router: Router(navigationController: UINavigationController()))
        coordinator.parentCoordinator = self
        addChild(coordinator)
        coordinator.start()
    }
}
