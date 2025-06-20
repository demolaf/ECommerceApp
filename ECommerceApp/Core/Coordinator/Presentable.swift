//
//  Presentable.swift
//  ECommerceApp
//
//  Created by Ademola Fadumo on 20/06/2025.
//

import UIKit

public protocol Presentable {
    @MainActor func toPresentable() -> UIViewController
}

extension UIViewController: Presentable {
    @MainActor public func toPresentable() -> UIViewController {
        return self
    }
}
