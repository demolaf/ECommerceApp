//
//  Toast.swift
//  ECommerceApp
//
//  Created by Ademola Fadumo on 21/06/2025.
//

import UIKit

public class Toast: UIView {
    
    // MARK: - Enums
    
    public enum ToastType {
        case info
        case success
        case error
    }
    
    public enum ToastPosition {
        case top
        case center
        case bottom
    }
    
    // MARK: - UI Components
    
    private let containerView = UIView()
    private let messageLabel = UILabel()
    private let iconImageView = UIImageView()
    private let closeButton = UIButton(type: .custom)
    private let dividerView = UIView()
    
    // MARK: - Properties
    
    private var toastType: ToastType = .info
    private var message: String = ""
    private var dismissTimer: Timer?
    private var dismissCompletion: (() -> Void)?
    
    // MARK: - Initialization
    
    private init(message: String, type: ToastType) {
        self.message = message
        self.toastType = type
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        setupContainerView()
        setupIconImageView()
        setupCloseButton()
        setupDividerView()
        setupMessageLabel()
        applyToastStyle()
    }
    
    private func setupContainerView() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.layer.cornerRadius = 8
        containerView.clipsToBounds = true
        
        // Add shadow layer to self (the parent view) so shadow appears behind the container
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.1
        self.layer.shadowRadius = 4
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.cornerRadius = 8 // Match the corner radius
        self.backgroundColor = .clear
        
        addSubview(containerView)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    private func setupIconImageView() {
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.contentMode = .scaleAspectFit
        containerView.addSubview(iconImageView)
        
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            iconImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 22),
            iconImageView.heightAnchor.constraint(equalToConstant: 22)
        ])
    }
    
    private func setupDividerView() {
        dividerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(dividerView)
        
        NSLayoutConstraint.activate([
            dividerView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            dividerView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8),
            dividerView.widthAnchor.constraint(equalToConstant: 1),
            dividerView.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: -12)
        ])
    }
    
    private func setupCloseButton() {
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 12, weight: .regular)
        closeButton.setImage(UIImage(systemName: "xmark")?.withConfiguration(symbolConfig), for: .normal)
        closeButton.addTarget(self, action: #selector(dismissToast), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            closeButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            closeButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 16),
            closeButton.heightAnchor.constraint(equalToConstant: 16)
        ])
    }
    
    private func setupMessageLabel() {
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.text = message
        messageLabel.numberOfLines = 0
        messageLabel.font = .systemFont(ofSize: 14, weight: .medium)
        messageLabel.textAlignment = .left
        containerView.addSubview(messageLabel)
        
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            messageLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            messageLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            messageLabel.trailingAnchor.constraint(equalTo: dividerView.leadingAnchor, constant: -12)
        ])
    }
    
    private func applyToastStyle() {
        switch toastType {
        case .success:
            containerView.backgroundColor = Colors.darkGreen
            messageLabel.textColor = .white
            closeButton.tintColor = .white
            iconImageView.image = UIImage(systemName: "checkmark.circle")
            iconImageView.tintColor = .white
            dividerView.backgroundColor = .white
        case .error:
            containerView.backgroundColor = Colors.darkRed
            messageLabel.textColor = .white
            closeButton.tintColor = .white
            iconImageView.image = UIImage(systemName: "exclamationmark.triangle")
            iconImageView.tintColor = .white
            dividerView.backgroundColor = .white
        case .info:
            containerView.backgroundColor = .systemGray3
            messageLabel.textColor = .label
            closeButton.tintColor = .label
            iconImageView.image = UIImage(systemName: "info.circle")
            iconImageView.tintColor = .label
            dividerView.backgroundColor = .gray
        }
    }
    
    // MARK: - Actions
    
    @objc private func dismissToast() {
        dismissTimer?.invalidate()
        removeWithAnimation()
    }
    
    private func removeWithAnimation() {
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0
        }, completion: { _ in
            self.removeFromSuperview()
            self.dismissCompletion?()
        })
    }
    
    // MARK: - Public Functions
    
    public static func show(
        type: ToastType = .info,
        message: String,
        position: ToastPosition = .top,
        duration: TimeInterval = 3.0,
        dismissible: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }
        
        let toast = Toast(message: message, type: type)
        toast.alpha = 0
        window.addSubview(toast)
        toast.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            toast.leadingAnchor.constraint(equalTo: window.leadingAnchor, constant: 16),
            toast.trailingAnchor.constraint(equalTo: window.trailingAnchor, constant: -16)
        ])
        
        // Position based on position enum
        switch position {
        case .top:
            toast.topAnchor.constraint(equalTo: window.safeAreaLayoutGuide.topAnchor, constant: 36).isActive = true
        case .center:
            toast.centerYAnchor.constraint(equalTo: window.centerYAnchor).isActive = true
        case .bottom:
            toast.bottomAnchor.constraint(equalTo: window.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        }
        
        // Show or hide close button based on dismissible
        toast.closeButton.isHidden = !dismissible
        
        if !dismissible {
            toast.dividerView.isHidden = true
        }
        
        // Animate toast in
        UIView.animate(withDuration: 0.3, animations: {
            toast.alpha = 1.0
        })
        
        toast.dismissCompletion = completion
        
        // Set timer to dismiss toast after duration
        toast.dismissTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { _ in
            Task { @MainActor in
                toast.removeWithAnimation()
            }
        }
    }
}
