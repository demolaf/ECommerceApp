//
//  Routable.swift
//  ECommerceApp
//
//  Created by Ademola Fadumo on 20/06/2025.
//


import Foundation
import UIKit

public protocol Routable: Presentable {
    @MainActor func push(_ module: Presentable, animated: Bool, completion: (() -> Void)?)
    @MainActor func pop(animated: Bool, completion: (() -> Void)?)
    @MainActor func pop(to vc: UIViewController.Type, animated: Bool, completion: (() -> Void)?)
    @MainActor func popToRoot(animated: Bool)
    // You can extend with more methods like:
    // func popModule(animated: Bool)
    // func present(_ module: Presentable, animated: Bool)
    // func dismissModule(animated: Bool, completion: (() -> Void)?)
}
