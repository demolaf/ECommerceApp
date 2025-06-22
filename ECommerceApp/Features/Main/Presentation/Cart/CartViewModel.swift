//
//  CartViewModel.swift
//  ECommerceApp
//
//  Created by Ademola Fadumo on 22/06/2025.
//

import Foundation
import RxSwift
import RxRelay
import RxCocoa

struct CartState: Equatable {
    enum ViewState: Equatable {
        case initial
        case loading
        case ready
        case placeOrder
        case error
    }
    
    var viewState: ViewState = .initial
    var processingState: ProcessingState?
    var user: User?
    var cart: Cart?
    var failureMessage: String?
    
    func copyWith(
        _ viewState: ViewState,
        processingState: ProcessingState? = nil,
        user: User? = nil,
        cart: Cart? = nil,
        failureMessage: String? = nil
    ) -> CartState {
        var newState = CartState()
        newState.viewState = viewState
        newState.processingState = processingState ?? self.processingState
        newState.user = user ?? self.user
        newState.cart = cart ?? self.cart
        newState.failureMessage = failureMessage ?? self.failureMessage
        return newState
    }
}

class CartViewModel {
    init(state: CartState = .init(), securityRepository: SecurityRepository, productRepository: ProductRepository) {
        self._state = .init(value: state)
        self.securityRepository = securityRepository
        self.productRepository = productRepository
        
        updateState(state.copyWith(.initial))
    }
    
    
    private let _state: BehaviorRelay<CartState>
    private let securityRepository: SecurityRepository
    private let productRepository: ProductRepository
    
    var state: Driver<CartState> {
        _state
            .distinctUntilChanged()
            .asDriver(onErrorDriveWith: .empty())
    }
    
    var currentState: CartState {
        _state.value
    }
    
    private func updateState(_ state: CartState) {
        if currentState == state { return }
        self._state.accept(state)
    }
    
    private let bag = DisposeBag()
    
    func initialize() {
        fetchCurrentUser()
    }
    
    func fetchCurrentUser() {
        updateState(currentState.copyWith(.loading))
        let result = securityRepository.checkSessionExists()
        switch result {
        case .success(let user):
            updateState(currentState.copyWith(.ready, user: user))
            fetchCart()
        case .failure(let failure):
            updateState(currentState.copyWith(.error, failureMessage: failure.localizedDescription))
        }
    }
    
    func fetchCart() {
        updateState(currentState.copyWith(.loading))
        let result = productRepository.getCart()
        switch result {
        case .success(let cart):
            updateState(currentState.copyWith(.ready, cart: cart))
        case .failure(let failure):
            updateState(currentState.copyWith(.error, failureMessage: failure.localizedDescription))
        }
    }
    
    func placeOrder() async {
        guard let cart = currentState.cart else {
            //TODO(demolaf): handle no existing cart state
            return
        }
        
        updateState(currentState.copyWith(.placeOrder, processingState: .processing))
        let result = await productRepository.placeOrder(userId: currentState.user?.uid ?? "", cart: cart)
        switch result {
        case .success(let success):
            updateState(currentState.copyWith(.placeOrder, processingState: .success))
        case .failure(let failure):
            updateState(currentState.copyWith(.placeOrder, processingState: .failure))
        }
    }
}
