//
//  Coordinatable.swift
//  ECommerceApp
//
//  Created by Ademola Fadumo on 20/06/2025.
//

import Foundation

/// The base interface for any Coordinator in the app.
public protocol Coordinatable: AnyObject, Presentable {
    var parentCoordinator: Coordinatable? { get set }
    var childCoordinators: [Coordinatable] { get set }

    /// Starts the navigation or logic flow.
    @MainActor func start()

    /// Called when the coordinator is done and should be cleaned up.
    func finish()

    /// Adds a child coordinator and retains it.
    func addChild(_ coordinator: Coordinatable)

    /// Removes a specific child coordinator.
    func removeChild(_ coordinator: Coordinatable)

    /// Handles when a child coordinator finishes.
    func childDidFinish(_ child: Coordinatable?)
}

// Default implementation to remove child coordinator
public extension Coordinatable {
    func addChild(_ coordinator: Coordinatable) {
        childCoordinators.append(coordinator)
        coordinator.parentCoordinator = self
    }
    
    func removeChild(_ coordinator: Coordinatable) {
        childCoordinators = childCoordinators.filter { $0 !== coordinator }
    }
    
    func childDidFinish(_ child: Coordinatable?) {
        if let child = child {
            removeChild(child)
        }
    }
    
    func finish() {
        // Clear all child coordinators
        childCoordinators.forEach { $0.finish() }
        childCoordinators.removeAll()
        
        // Notify parent that this coordinator is done
        parentCoordinator?.childDidFinish(self)
    }
}
