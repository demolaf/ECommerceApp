# ECommerceApp

https://github.com/user-attachments/assets/0ab08da7-9b05-4184-9573-142e1f8d5b4d

A modern iOS e-commerce application built with Swift, UIKit, and a clean architecture. The app allows users to browse products, add items to a cart, and place orders, with robust offline support and real-time updates.

## Features

- **Product Browsing:** Users can view a list of products with images and details.
- **Cart Management:** Add/remove products to/from the cart and place orders.
- **Order Tracking:** View past orders and their statuses.
- **User Authentication:** Sign up, log in, and manage sessions using Firebase Auth.
- **Offline Support:** Core Data is used for local caching and offline access.
- **Real-time Updates:** Product and order data are synced in real-time with Firebase Firestore.

## Architecture & Technologies

- **UIKit & UICollectionView:**
  - Product, cart, and order lists are displayed using `UICollectionView` with compositional layouts for a modern, flexible UI.
  - Custom cells (e.g., `ProductCollectionViewCell`, `OrdersCollectionViewCell`) provide rich, interactive item displays.

- **Diffable Data Sources:**
  - All collection views use `UICollectionViewDiffableDataSource` and `NSDiffableDataSourceSnapshot` for efficient, animated updates and smooth UI changes.

- **Reactive Programming with RxSwift:**
  - The app leverages `RxSwift` and `RxCocoa` for reactive streams, binding view models to UI and handling user interactions.
  - Observables are used to stream data from both local Core Data and remote Firebase Firestore, ensuring the UI always reflects the latest data.

- **Firebase Firestore:**
  - Real-time product and order data are fetched and updated using Firestore listeners, exposed as RxSwift `Observable`s.
  - Example: `ProductRemoteDatasourceImpl` uses Firestore's `addSnapshotListener` to push updates to the app reactively.

- **Core Data:**
  - Local storage is managed with Core Data, providing offline access and caching for products, cart, and orders.
  - The app uses `NSFetchedResultsController` wrapped in a custom RxSwift observable (`FetchedResultsControllerObserver`) to stream Core Data changes reactively.

- **Dependency Injection:**
  - All services, datasources, and repositories are managed via a `DependencyContainer` for testability and modularity.

## Project Structure

- `Features/` — Modularized by feature (Auth, Main, Shared)
- `Core/` — Common utilities, Core Data stack, and extensions
- `App/` — App delegate, dependency container, and launch coordination

## Setup & Requirements

- Xcode 15+
- Swift 6
- CocoaPods or Swift Package Manager dependencies:
  - [RxSwift](https://github.com/ReactiveX/RxSwift)
  - [Firebase/Auth, Firestore](https://firebase.google.com/docs/ios/setup)
  - [Kingfisher](https://github.com/onevcat/Kingfisher) (for image loading)

### 🚨 Important: GoogleService-Info.plist Placement

You **must** download your `GoogleService-Info.plist` from the Firebase Console and place it in the `ECommerceApp/Supporting Files/` directory. The app will not build or connect to Firebase services without this file in the correct location.

### Firebase Setup
1. Create a Firebase project and add an iOS app.
2. Download `GoogleService-Info.plist` and place it in `ECommerceApp/Supporting Files/` (**see above**).
3. Enable Firestore and Authentication (Email/Password) in the Firebase console.

### Running the App
1. Install dependencies via CocoaPods or SPM.
2. Open `ECommerceApp.xcodeproj` in Xcode.
3. Build and run on a simulator or device.

## Notable Code Highlights

- **UICollectionView + Diffable Data Source:**
  - See `HomeViewController.swift`, `CartViewController.swift`, `OrdersViewController.swift` for compositional layouts and diffable data source usage.
- **Reactive Streams:**
  - View models expose state as RxSwift `Driver`s, and Firestore/Core Data changes are observed reactively.
- **Core Data Observables:**
  - `FetchedResultsControllerObserver` bridges Core Data changes to RxSwift observables for seamless UI updates.

## License

MIT 
