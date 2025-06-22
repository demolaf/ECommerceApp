//
//  AuthCoordinator.swift
//  ECommerceApp
//
//  Created by Ademola Fadumo on 20/06/2025.
//

import UIKit

class AuthCoordinator: Coordinator {
    override func start() {
        let result = DependencyContainer.shared.securityRepository.checkSessionExists()
        switch result {
        case .success:
            navigateToHome()
        case .failure:
            navigateToLogin()
        }
    }
    
    func navigateToLogin() {
        let viewModel = LoginViewModel(securityRepository: DependencyContainer.shared.securityRepository)
        let vc = LoginViewController(viewModel: viewModel)
        vc.coordinator = self
        vc.navigationItem.hidesBackButton = true
        router.push(vc)
    }
    
    func popToLogin() {
        router.pop(to: LoginViewController.self)
    }
    
    func navigateToSignup() {
        let viewModel = SignupViewModel(securityRepository: DependencyContainer.shared.securityRepository)
        let vc = SignupViewController(viewModel: viewModel)
        vc.coordinator = self
        router.push(vc)
    }
    
    func navigateToHome() {
        let coordinator = MainCoordinator(router: router)
        coordinator.parentCoordinator = self
        addChild(coordinator)
        coordinator.start()
    }
}
