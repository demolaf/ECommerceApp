//
//  DetailViewController.swift
//  ECommerceApp
//
//  Created by Ademola Fadumo on 20/06/2025.
//

import UIKit

class DetailViewController: UIViewController {
    weak var coordinator: MainCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Detail"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .systemBackground
    }
}
