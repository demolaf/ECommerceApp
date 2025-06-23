//
//  OrdersViewModel.swift
//  ECommerceApp
//
//  Created by Ademola Fadumo on 20/06/2025.
//

import Foundation
import RxSwift
import RxRelay
import RxCocoa

struct OrdersState: Equatable {
    enum ViewState: Equatable {
        case initial
        case loading
        case ready
        case error
    }
    
    var viewState: ViewState = .initial
    var processingState: ProcessingState?
    var user: User?
    var orders: [Order] = []
    var failureMessage: String?
    
    func copyWith(
        _ viewState: ViewState,
        processingState: ProcessingState? = nil,
        user: User? = nil,
        orders: [Order]? = nil,
        failureMessage: String? = nil
    ) -> OrdersState {
        var newState = OrdersState()
        newState.viewState = viewState
        newState.processingState = processingState ?? self.processingState
        newState.user = user ?? self.user
        newState.orders = orders ?? self.orders
        newState.failureMessage = failureMessage ?? self.failureMessage
        return newState
    }
}

class OrdersViewModel {
    init(state: OrdersState = .init(), securityRepository: SecurityRepository, productRepository: ProductRepository) {
        self._state = .init(value: state)
        self.securityRepository = securityRepository
        self.productRepository = productRepository
        updateState(state.copyWith(.initial))
    }
    
    
    private let _state: BehaviorRelay<OrdersState>
    private let securityRepository: SecurityRepository
    private let productRepository: ProductRepository
    
    var state: Driver<OrdersState> {
        _state
            .distinctUntilChanged()
            .asDriver(onErrorDriveWith: .empty())
    }
    
    var currentState: OrdersState {
        _state.value
    }
    
    private func updateState(_ state: OrdersState) {
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
            fetchOrders()
        case .failure(let failure):
            updateState(currentState.copyWith(.error, failureMessage: failure.localizedDescription))
        }
    }

    func fetchOrders() {
        updateState(currentState.copyWith(.loading))
        productRepository.getOrders(userId: currentState.user?.uid ?? "")
            .subscribe(onNext: { [weak self] result in
                guard let self else { return }
                switch result {
                case .success(let orders):
                    updateState(currentState.copyWith(.ready, orders: orders))
                case .failure(let failure):
                    updateState(currentState.copyWith(.error, failureMessage: failure.localizedDescription))
                }
            })
            .disposed(by: bag)
    }
}
