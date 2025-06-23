//
//  HomeViewModel.swift
//  ECommerceApp
//
//  Created by Ademola Fadumo on 20/06/2025.
//

import Foundation
import RxSwift
import RxRelay
import RxCocoa

struct HomeState: Equatable {
    enum ViewState: Equatable {
        case initial
        case loading
        case ready
        case fetchOrders
        case fetchCart
        case addToCart
        case error
    }
    
    var viewState: ViewState = .initial
    var processingState: ProcessingState?
    var user: User?
    var products: [Product] = []
    var cart: Cart?
    var orders: [Order] = []
    var failureMessage: String?
    
    func copyWith(
        _ viewState: ViewState,
        processingState: ProcessingState? = nil,
        user: User? = nil,
        products: [Product]? = nil,
        cart: Cart? = nil,
        orders: [Order]? = nil,
        failureMessage: String? = nil
    ) -> HomeState {
        var newState = HomeState()
        newState.viewState = viewState
        newState.processingState = processingState ?? self.processingState
        newState.user = user ?? self.user
        newState.products = products ?? self.products
        newState.cart = cart ?? self.cart
        newState.orders = orders ?? self.orders
        newState.failureMessage = failureMessage ?? self.failureMessage
        return newState
    }
}

class HomeViewModel {
    init(state: HomeState = .init(), securityRepository: SecurityRepository, productRepository: ProductRepository) {
        self._state = .init(value: state)
        self.securityRepository = securityRepository
        self.productRepository = productRepository
        
        updateState(state.copyWith(.initial))
    }
    
    
    private let _state: BehaviorRelay<HomeState>
    private let securityRepository: SecurityRepository
    private let productRepository: ProductRepository
    
    var state: Driver<HomeState> {
        _state
            .distinctUntilChanged()
            .asDriver(onErrorDriveWith: .empty())
    }
    
    var currentState: HomeState {
        _state.value
    }
    
    private func updateState(_ state: HomeState) {
        if currentState == state { return }
        self._state.accept(state)
    }
    
    private let bag = DisposeBag()
    
    func initialize() {
        fetchCurrentUser()
        fetchProducts()
    }
    
    func fetchCurrentUser() {
        updateState(currentState.copyWith(.loading))
        let result = securityRepository.checkSessionExists()
        switch result {
        case .success(let user):
            updateState(currentState.copyWith(.ready, user: user))
            fetchCart()
            fetchOrders()
        case .failure(let failure):
            updateState(currentState.copyWith(.error, failureMessage: failure.localizedDescription))
        }
    }
    
    func fetchCart() {
        updateState(currentState.copyWith(.fetchCart, processingState: .processing))
        productRepository.getCart()
            .subscribe(onNext: { [weak self] result in
                guard let self else { return }
                switch result {
                case .success(let cart):
                    updateState(currentState.copyWith(.fetchCart, processingState: .success, cart: cart))
                case .failure(let failure):
                    updateState(currentState.copyWith(.fetchCart, processingState: .failure, failureMessage: failure.localizedDescription))
                }
            })
            .disposed(by: bag)
    }
    
    func fetchOrders() {
        updateState(currentState.copyWith(.fetchOrders, processingState: .processing))
        productRepository.getOrders(userId: currentState.user?.uid ?? "")
            .subscribe(onNext: { [weak self] result in
                guard let self else { return }
                switch result {
                case .success(let orders):
                    updateState(currentState.copyWith(.fetchOrders, processingState: .success, orders: orders))
                case .failure(let failure):
                    updateState(currentState.copyWith(.fetchOrders, processingState: .failure, failureMessage: failure.localizedDescription))
                }
            })
            .disposed(by: bag)
    }
    
    func fetchProducts() {
        updateState(currentState.copyWith(.loading))
        productRepository.getProducts()
            .subscribe(onNext: { [weak self] result in
                guard let self else { return }
                switch result {
                case .success(let products):
                    updateState(currentState.copyWith(.ready, products: products))
                case .failure(let failure):
                    updateState(currentState.copyWith(.error, failureMessage: failure.localizedDescription))
                }
            })
            .disposed(by: bag)
    }
    
    func addToCart(_ product: Product) {
        updateState(currentState.copyWith(.addToCart, processingState: .processing))
        
        let result = switch productRepository.checkIfProductInCart(product.id) {
        case .success(let product):
            productRepository.removeFromCart(product.id)
        case .failure:
            productRepository.addToCart(product)
        }
        
        switch result {
        case .success:
            updateState(currentState.copyWith(.addToCart, processingState: .success))
        case .failure(let failure):
            updateState(currentState.copyWith(.addToCart, processingState: .failure, failureMessage: failure.localizedDescription))
        }
    }
    
    func logout() {
        productRepository.clearCart()
        securityRepository.logout()
    }
}
