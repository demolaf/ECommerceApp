//
//  AppDelegate.swift
//  ECommerceApp
//
//  Created by Ademola Fadumo on 16/06/2025.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import CoreData

// TODO:
// 1.) Build a simple e-commerce app where users can browse products, add items to a cart, and place orders. ✅
// 2.) Implement user authentication (signup/login) using Firebase or another authentication service. ✅
// 3.) Use a RecyclerView to display the product list, ensuring smooth scrolling and efficient image loading. ✅
// 4.) Incorporate local data storage for offline access and caching.
// 5.) Implement unit and integration tests for key components.

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        return true
    }
}
