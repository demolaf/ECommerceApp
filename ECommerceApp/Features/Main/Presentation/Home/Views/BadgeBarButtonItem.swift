//
//  BadgeBarButtonItem.swift
//  ECommerceApp
//
//  Created by Ademola Fadumo on 22/06/2025.
//

import UIKit

class BadgeBarButtonItem: UIBarButtonItem {

    // MARK: - Public Properties
    let button = UIButton(type: .custom)

    var badgeValue: Int = 0 {
        didSet {
            updateBadge()
        }
    }

    // MARK: - Private Properties
    private let badgeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textColor = .white
        label.backgroundColor = .systemRed
        label.textAlignment = .center
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Init
    init(image: UIImage, target: Any?, action: Selector?) {
        super.init()
        setupButton(image: image, target: target, action: action)
        self.customView = button
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup
    private func setupButton(image: UIImage, target: Any?, action: Selector?) {
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 32).isActive = true
        button.heightAnchor.constraint(equalToConstant: 32).isActive = true

        button.addSubview(badgeLabel)

        NSLayoutConstraint.activate([
            badgeLabel.topAnchor.constraint(equalTo: button.topAnchor, constant: -4),
            badgeLabel.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: 4),
            badgeLabel.heightAnchor.constraint(equalToConstant: 20),
            badgeLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 20)
        ])

        if let action = action {
            button.addTarget(target, action: action, for: .touchUpInside)
        }

        updateBadge()
    }

    // MARK: - Badge Update
    private func updateBadge() {
        badgeLabel.isHidden = badgeValue <= 0
        badgeLabel.text = "\(badgeValue)"
    }
}
