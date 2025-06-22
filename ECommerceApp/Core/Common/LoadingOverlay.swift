//
//  LoadingOverlay.swift
//  ECommerceApp
//
//  Created by Ademola Fadumo on 21/06/2025.
//

import UIKit

final class LoadingOverlay {
    
    // MARK: - Static
    private static let shared = LoadingOverlay()
    
    static func show() {
        DispatchQueue.main.async {
            shared.show()
        }
    }
    
    static func hide() {
        DispatchQueue.main.async {
            shared.hide()
        }
    }

    // MARK: - Private Properties
    
    private var overlayView: UIView?
    private var activityIndicatorBackgroundView: UIView?
    private var activityIndicator: UIActivityIndicatorView?

    // MARK: - Private Methods

    private func show() {
        guard overlayView == nil,
              let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }

        let overlay = UIView(frame: window.bounds)
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.5)

        // Create background container
        let activityIndicatorBackgroundView = UIView()
        activityIndicatorBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorBackgroundView.backgroundColor = .darkGray
        activityIndicatorBackgroundView.layer.cornerRadius = 16
        activityIndicatorBackgroundView.clipsToBounds = true

        // Create activity indicator
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .white
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.startAnimating()

        // Assemble views
        activityIndicatorBackgroundView.addSubview(indicator)
        overlay.addSubview(activityIndicatorBackgroundView)
        window.addSubview(overlay)

        // Layout constraints
        NSLayoutConstraint.activate([
            activityIndicatorBackgroundView.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
            activityIndicatorBackgroundView.centerYAnchor.constraint(equalTo: overlay.centerYAnchor),
            activityIndicatorBackgroundView.widthAnchor.constraint(equalToConstant: 56),
            activityIndicatorBackgroundView.heightAnchor.constraint(equalToConstant: 56),

            indicator.centerXAnchor.constraint(equalTo: activityIndicatorBackgroundView.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: activityIndicatorBackgroundView.centerYAnchor),
        ])

        self.overlayView = overlay
        self.activityIndicator = indicator
    }

    private func hide() {
        activityIndicator?.stopAnimating()
        overlayView?.removeFromSuperview()

        activityIndicator = nil
        overlayView = nil
    }
}
