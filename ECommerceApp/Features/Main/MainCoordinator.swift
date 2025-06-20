//
//  MainCoordinator.swift
//  ECommerceApp
//
//  Created by Ademola Fadumo on 20/06/2025.
//

import UIKit

class MainCoordinator: Coordinator {
    override func start() {
        let vc = HomeViewController()
        router.push(vc)
    }
    
    func navigateToDetail() {
        let vc = DetailViewController()
        router.push(vc)
    }
}
