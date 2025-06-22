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
        
        // Add image icon
        let box = UILabel()
        box.text = "📦"
        box.font = .systemFont(ofSize: height / 1.5)
        box.translatesAutoresizingMaskIntoConstraints = false
        floatingActionButton.addSubview(box)
        
        NSLayoutConstraint.activate([
            box.centerXAnchor.constraint(equalTo: floatingActionButton.centerXAnchor),
            box.centerYAnchor.constraint(equalTo: floatingActionButton.centerYAnchor),
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
        primaryActionTapped?()
    }
}
