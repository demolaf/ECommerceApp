//
//  ProductCollectionViewCell.swift
//  ECommerceApp
//
//  Created by Ademola Fadumo on 22/06/2025.
//

import UIKit
import Kingfisher

final class ProductCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "ProductCell"
    
    private var contentVStack: UIStackView!
    private var imageView: UIImageView!
    private var nameLabel: UILabel!
    private var priceLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeViewAppearance()
        setupContentVStack()
        setupImageView()
        setupNameLabel()
        setupPriceLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        nameLabel.text = nil
        priceLabel.text = nil
    }
    
    private func initializeViewAppearance() {
        contentView.backgroundColor = .secondarySystemGroupedBackground
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
    
    private func setupImageView() {
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        contentVStack.addArrangedSubview(imageView)
    }
    
    private func setupNameLabel() {
        nameLabel = UILabel()
        nameLabel.font = .systemFont(ofSize: 16, weight: .medium)
        nameLabel.numberOfLines = 1
        contentVStack.addArrangedSubview(nameLabel)
    }
    
    private func setupPriceLabel() {
        priceLabel = UILabel()
        priceLabel.font = .systemFont(ofSize: 14)
        priceLabel.textColor = .secondaryLabel
        contentVStack.addArrangedSubview(priceLabel)
    }
    
    func configure(with product: Product) {
        nameLabel.text = product.name
        priceLabel.text = String(format: "$%.2f", product.price)
        imageView.kf.setImage(with: URL(string: product.photoUrl))
    }
}
