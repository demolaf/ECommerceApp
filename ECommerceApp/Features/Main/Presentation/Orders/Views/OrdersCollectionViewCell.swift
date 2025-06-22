//
//  OrdersCollectionViewCell.swift
//  ECommerceApp
//
//  Created by Ademola Fadumo on 22/06/2025.
//

import UIKit

final class OrdersCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "OrdersCollectionViewCell"
    
    private var contentVStack: UIStackView!
    private var titleLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeViewAppearance()
        setupContentVStack()
        setupTitleLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
    }
    
    private func initializeViewAppearance() {
        // contentView.backgroundColor = .secondarySystemGroupedBackground
        contentView.layer.cornerRadius = 12
        contentView.clipsToBounds = true
    }
    
    private func setupContentVStack() {
        contentVStack = UIStackView()
        contentVStack.axis = .vertical
        contentVStack.spacing = 8
        contentVStack.alignment = .fill
        contentVStack.distribution = .fill
        contentVStack.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(contentVStack)
        
        NSLayoutConstraint.activate([
            contentVStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            contentVStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            contentVStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            contentVStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    private func setupTitleLabel() {
        titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        titleLabel.numberOfLines = 1
        contentVStack.addArrangedSubview(titleLabel)
    }
    
    func configure(with order: Order) {
        titleLabel.text = order.id.uuidString
    }
}
