//
//  DefaultButton.swift
//  ECommerceApp
//
//  Created by Ademola Fadumo on 20/06/2025.
//

import UIKit

class DefaultButton: UIView {
    private(set) var button: UIButton!
    
    public var isEnabled: Bool = true {
        didSet {
            button.isEnabled = isEnabled
            updateAppearanceForEnabledState()
        }
    }
    
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
        button.isEnabled = isEnabled
        
        addSubview(button)
        
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: leadingAnchor),
            button.trailingAnchor.constraint(equalTo: trailingAnchor),
            button.topAnchor.constraint(equalTo: topAnchor),
            button.bottomAnchor.constraint(equalTo: bottomAnchor),
            button.heightAnchor.constraint(equalToConstant: 48),
        ])
        
        updateAppearanceForEnabledState()
    }
    
    private func updateAppearanceForEnabledState() {
        if isEnabled {
            button.backgroundColor = .label
            button.setTitleColor(.systemBackground, for: .normal)
            button.alpha = 1.0
        } else {
            button.backgroundColor = .systemGray3
            button.setTitleColor(.label, for: .normal)
            button.alpha = 0.6
        }
    }
}
