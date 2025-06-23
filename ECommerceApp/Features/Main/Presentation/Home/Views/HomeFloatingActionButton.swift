//
//  HomeFloatingActionButton.swift
//  ECommerceApp
//
//  Created by Ademola Fadumo on 22/06/2025.
//

import UIKit

class HomeFloatingActionButton: UIView {
    private var contentVStack: UIStackView!
    private var floatingActionButton: UIView!
    private var expandableVStack: UIStackView!
    
    var primaryActionTapped: (() -> Void)?
    
    init(primaryActionTapped: (() -> Void)? = nil) {
        self.primaryActionTapped = primaryActionTapped
        super.init(frame: .zero)
        setupContentVStack()
        setupFloatingActionButton()
        setupExpandableVStack()
        setupExpandableItems()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupContentVStack() {
        contentVStack = UIStackView()
        contentVStack.axis = .vertical
        contentVStack.spacing = 16
        contentVStack.alignment = .fill
        contentVStack.distribution = .fill
        contentVStack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(contentVStack)
        
        NSLayoutConstraint.activate([
            contentVStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentVStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentVStack.topAnchor.constraint(equalTo: topAnchor),
            contentVStack.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    private func setupFloatingActionButton() {
        let height: CGFloat = 84.0
        floatingActionButton = UIView()
        floatingActionButton.layer.cornerRadius = height / 2
        floatingActionButton.clipsToBounds = true // Important for corner radius masking
        floatingActionButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(primaryActionButtonTapped)))
        floatingActionButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Add blur or glass effect view
        let visualEffect: UIVisualEffectView
        if #available(iOS 26.0, *) {
            visualEffect = UIVisualEffectView(effect: UIGlassEffect())
        } else {
            visualEffect = UIVisualEffectView(effect: UIBlurEffect(style: .systemThickMaterial))
        }
        visualEffect.translatesAutoresizingMaskIntoConstraints = false
        floatingActionButton.addSubview(visualEffect)
        
        NSLayoutConstraint.activate([
            visualEffect.leadingAnchor.constraint(equalTo: floatingActionButton.leadingAnchor),
            visualEffect.trailingAnchor.constraint(equalTo: floatingActionButton.trailingAnchor),
            visualEffect.topAnchor.constraint(equalTo: floatingActionButton.topAnchor),
            visualEffect.bottomAnchor.constraint(equalTo: floatingActionButton.bottomAnchor)
        ])
        
        // Create a container for the emoji and plus icon
        let iconContainer = UIView()
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        floatingActionButton.addSubview(iconContainer)
        NSLayoutConstraint.activate([
            iconContainer.centerXAnchor.constraint(equalTo: floatingActionButton.centerXAnchor),
            iconContainer.centerYAnchor.constraint(equalTo: floatingActionButton.centerYAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: height * 0.7),
            iconContainer.heightAnchor.constraint(equalToConstant: height * 0.7)
        ])
        
        // Add emoji label
        let box = UILabel()
        box.text = "📦"
        box.font = .systemFont(ofSize: height / 1.5)
        box.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.addSubview(box)
        NSLayoutConstraint.activate([
            box.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            box.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor)
        ])
        
        // Add plus icon in bottom right
        let plusImageView = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: height / 3, weight: .black)
        plusImageView.image = UIImage(systemName: "plus", withConfiguration: config)
        plusImageView.tintColor = .white
        plusImageView.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.addSubview(plusImageView)
        NSLayoutConstraint.activate([
            plusImageView.trailingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 4),
            plusImageView.bottomAnchor.constraint(equalTo: iconContainer.bottomAnchor, constant: 2)
        ])
        
        contentVStack.addArrangedSubview(floatingActionButton)
        
        NSLayoutConstraint.activate([
            floatingActionButton.widthAnchor.constraint(equalToConstant: height),
            floatingActionButton.heightAnchor.constraint(equalToConstant: height),
        ])
    }
    
    private func setupExpandableVStack() {
        expandableVStack = UIStackView()
        expandableVStack.axis = .vertical
        expandableVStack.spacing = 16
        expandableVStack.alignment = .fill
        expandableVStack.distribution = .fill
        
        contentVStack.addArrangedSubview(expandableVStack)
    }
    
    private func setupExpandableItems() {
        
    }
    
    private func createItem() {
        
    }
    
    @objc private func primaryActionButtonTapped() {
        // Bounce animation
        UIView.animate(withDuration: 0.1) { [weak self] in
            self?.floatingActionButton.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        } completion: { [weak self] _ in
            UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 6, options: .curveEaseInOut) {
                self?.floatingActionButton.transform = .identity
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.primaryActionTapped?()
            }
        }
    }
}
