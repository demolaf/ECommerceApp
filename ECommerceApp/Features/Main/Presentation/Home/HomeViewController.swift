//
//  HomeViewController.swift
//  ECommerceApp
//
//  Created by Ademola Fadumo on 16/06/2025.
//

import UIKit

class HomeViewController: UIViewController {
    
    weak var coordinator: MainCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Home"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .systemBackground
    }
}

