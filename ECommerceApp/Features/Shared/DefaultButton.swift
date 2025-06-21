//
//  DefaultButton.swift
//  ECommerceApp
//
//  Created by Ademola Fadumo on 20/06/2025.
//

import UIKit

class DefaultButton: UIView {
    private(set) var button: UIButton!
    
    init() {
        super.init(frame: .zero)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupButton() {
        button = UIButton()
        button.setTitleColor(.systemBackground, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        button.layer.cornerRadius = 16
        button.backgroundColor = .label
        button.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(button)
        
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: leadingAnchor),
            button.trailingAnchor.constraint(equalTo: trailingAnchor),
            button.topAnchor.constraint(equalTo: topAnchor),
            button.bottomAnchor.constraint(equalTo: bottomAnchor),
            button.heightAnchor.constraint(equalToConstant: 48),
        ])
    }
}
