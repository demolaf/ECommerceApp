//
//  Router.swift
//  ECommerceApp
//
//  Created by Ademola Fadumo on 20/06/2025.
//

import UIKit

public protocol RouterDelegate: AnyObject {
    func navigationController(didShow: UIViewController)
}

open class Router: NSObject, Routable {
    public var completions: [UIViewController: () -> Void]
    public let navigationController: UINavigationController
    
    weak public var delegate: RouterDelegate?
    
    @MainActor public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.completions = [:]
        super.init()
        
        self.navigationController.delegate = self
    }
    
    private func runCompletion(for controller: UIViewController) {
        guard let completion = completions[controller] else { return }
        completion()
        completions.removeValue(forKey: controller)
    }
    
    @MainActor public func push(_ module: Presentable, animated: Bool = true, completion: (() -> Void)? = nil) {
        let controller = module.toPresentable()
        if let completion = completion {
            completions[controller] = completion
        }
        navigationController.pushViewController(controller, animated: animated)
    }
    
    @MainActor
    public func pop(animated: Bool = true, completion: (() -> Void)? = nil) {
        if let poppedVC = navigationController.popViewController(animated: animated) {
            runCompletion(for: poppedVC)
        }
    }
    
    @MainActor
    public func pop(to vc: UIViewController.Type, animated: Bool = true, completion: (() -> Void)? = nil) {
        if let existingVC = navigationController.viewControllers.first(where: { type(of: $0) == vc }) {
            let poppedVCs = navigationController.popToViewController(existingVC, animated: animated)
            poppedVCs?.forEach { runCompletion(for: $0) }
        }
    }
    
    @MainActor public func popToRoot(animated: Bool) {
        let poppedVCs = navigationController.popToRootViewController(animated: animated) ?? []
        poppedVCs.forEach { runCompletion(for: $0) }
    }
}

extension Router: UINavigationControllerDelegate {
    public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        delegate?.navigationController(didShow: viewController)
    }
    
    public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        guard let poppedViewController = navigationController.transitionCoordinator?.viewController(forKey: .from),
              !navigationController.viewControllers.contains(poppedViewController) else {
            return
        }
        runCompletion(for: poppedViewController)
    }
}

extension Router: Presentable {
    public func toPresentable() -> UIViewController {
        return navigationController
    }
}
