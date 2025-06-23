//
//  BadgeBarButtonItem.swift
//  ECommerceApp
//
//  Created by Ademola Fadumo on 22/06/2025.
//

import UIKit

class BadgeBarButtonItem: UIBarButtonItem {
    private var badgeLabel: UILabel!
    private var button: UIButton!
    
    var badgeValue: Int = 0 {
        didSet {
            updateBadge()
        }
    }
    
    init(image: UIImage, target: Any?, action: Selector?) {
        super.init()
        setupBadgeLabel()
        setupButton(image: image, target: target, action: action)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupBadgeLabel() {
        badgeLabel = UILabel()
        badgeLabel.font = .systemFont(ofSize: 10, weight: .bold)
        badgeLabel.textColor = .white
        badgeLabel.backgroundColor = .systemRed
        badgeLabel.textAlignment = .center
        badgeLabel.layer.cornerRadius = 8
        badgeLabel.layer.masksToBounds = true
        badgeLabel.translatesAutoresizingMaskIntoConstraints = false
    }

    private func setupButton(image: UIImage, target: Any?, action: Selector?) {
        button = UIButton(type: .custom)
        customView = button
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false

        button.addSubview(badgeLabel)

        NSLayoutConstraint.activate([
            badgeLabel.topAnchor.constraint(equalTo: button.topAnchor, constant: 0),
            badgeLabel.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: 0),
            badgeLabel.heightAnchor.constraint(equalToConstant: 16),
            badgeLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 16)
        ])
        
        if let action {
            button.addTarget(target, action: action, for: .touchUpInside)
        }

        updateBadge()
    }

    private func updateBadge() {
        badgeLabel.isHidden = badgeValue <= 0
        badgeLabel.text = "\(badgeValue)"
    }
}
