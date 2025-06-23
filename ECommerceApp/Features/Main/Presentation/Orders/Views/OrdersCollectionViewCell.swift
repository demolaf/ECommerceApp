//
//  OrdersCollectionViewCell.swift
//  ECommerceApp
//
//  Created by Ademola Fadumo on 22/06/2025.
//

import UIKit

class OrdersCollectionViewCell: UICollectionViewListCell {
    static let reuseIdentifier = "OrdersCollectionViewCell"
    
    private var cardView: UIView!
    private var topRowStack: UIStackView!
    private var bottomRowStack: UIStackView!
    private var titleLabel: UILabel!
    private var statusLabel: UILabel!
    private var dateIcon: UIImageView!
    private var dateLabel: UILabel!
    private var productIcon: UIImageView!
    private var productCountLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeViewAppearance()
        setupCardView()
        setupTopRowStack()
        setupBottomRowStack()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        statusLabel.text = nil
        dateLabel.text = nil
        productCountLabel.text = nil
    }
    
    private func initializeViewAppearance() {
        backgroundColor = .clear
    }
    
    private func setupCardView() {
        cardView = UIView()
        cardView.layer.cornerRadius = 12
        cardView.clipsToBounds = false
        cardView.backgroundColor = .secondarySystemGroupedBackground
        // Shadow (match Toast style)
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.1
        cardView.layer.shadowRadius = 4
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cardView)
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4)
        ])
    }
    
    private func setupTopRowStack() {
        topRowStack = UIStackView()
        topRowStack.axis = .horizontal
        topRowStack.alignment = .center
        topRowStack.distribution = .equalSpacing
        topRowStack.spacing = 8
        topRowStack.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .label
        
        statusLabel = UILabel()
        statusLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        statusLabel.textAlignment = .right
        statusLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        topRowStack.addArrangedSubview(titleLabel)
        topRowStack.addArrangedSubview(statusLabel)
        
        cardView.addSubview(topRowStack)
        NSLayoutConstraint.activate([
            topRowStack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            topRowStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            topRowStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupBottomRowStack() {
        bottomRowStack = UIStackView()
        bottomRowStack.axis = .horizontal
        bottomRowStack.alignment = .center
        bottomRowStack.distribution = .equalSpacing
        bottomRowStack.spacing = 12
        bottomRowStack.translatesAutoresizingMaskIntoConstraints = false
        
        // Date
        dateIcon = UIImageView(image: UIImage(systemName: "calendar"))
        dateIcon.tintColor = .secondaryLabel
        dateIcon.contentMode = .scaleAspectFit
        dateIcon.translatesAutoresizingMaskIntoConstraints = false
        dateIcon.widthAnchor.constraint(equalToConstant: 16).isActive = true
        dateIcon.heightAnchor.constraint(equalToConstant: 16).isActive = true
        
        dateLabel = UILabel()
        dateLabel.font = .systemFont(ofSize: 13)
        dateLabel.textColor = .secondaryLabel
        
        let dateStack = UIStackView(arrangedSubviews: [dateIcon, dateLabel])
        dateStack.axis = .horizontal
        dateStack.spacing = 4
        dateStack.alignment = .center
        
        // Product count
        productIcon = UIImageView(image: UIImage(systemName: "bag"))
        productIcon.tintColor = .tertiaryLabel
        productIcon.contentMode = .scaleAspectFit
        productIcon.translatesAutoresizingMaskIntoConstraints = false
        productIcon.widthAnchor.constraint(equalToConstant: 16).isActive = true
        productIcon.heightAnchor.constraint(equalToConstant: 16).isActive = true
        
        productCountLabel = UILabel()
        productCountLabel.font = .systemFont(ofSize: 13)
        productCountLabel.textColor = .tertiaryLabel
        
        let productStack = UIStackView(arrangedSubviews: [productIcon, productCountLabel])
        productStack.axis = .horizontal
        productStack.spacing = 4
        productStack.alignment = .center
        
        bottomRowStack.addArrangedSubview(dateStack)
        bottomRowStack.addArrangedSubview(productStack)
        
        cardView.addSubview(bottomRowStack)
        NSLayoutConstraint.activate([
            bottomRowStack.topAnchor.constraint(equalTo: topRowStack.bottomAnchor, constant: 12),
            bottomRowStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            bottomRowStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            bottomRowStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16)
        ])
    }

    func configure(with order: Order) {
        titleLabel.text = "Order #\(order.id.uuidString.prefix(8))"
        statusLabel.text = "\(order.status.title)"
        dateLabel.text = formatted(date: order.createdAt)
        productCountLabel.text = "\(order.products.count) product(s)"
        statusLabel.textColor = order.status.color
    }

    private func formatted(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
