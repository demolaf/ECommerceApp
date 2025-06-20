//
//  SceneDelegate.swift
//  ECommerceApp
//
//  Created by Ademola Fadumo on 16/06/2025.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    var coordinator: LaunchCoordinator?
    
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        initialize(windowScene: windowScene)
    }
    
    private func initialize(windowScene: UIWindowScene) {
        let navigationController = UINavigationController()
        
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = navigationController
        
        coordinator = LaunchCoordinator(router: .init(navigationController: navigationController))
        coordinator?.start()
        
        self.window = window
        window.makeKeyAndVisible()
    }
}
