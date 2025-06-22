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
        case error
    }
    
    var viewState: ViewState = .initial
    var processingState: ProcessingState?
    var products: [Product] = []
    var failureMessage: String?
    
    func copyWith(
        _ viewState: ViewState,
        processingState: ProcessingState? = nil,
        products: [Product]? = nil,
        failureMessage: String? = nil
    ) -> HomeState {
        var newState = HomeState()
        newState.viewState = viewState
        newState.processingState = processingState ?? self.processingState
        newState.products = products ?? self.products
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
        fetchProducts()
    }
    
    func fetchProducts() {
        productRepository.getProducts()
            .subscribe(onNext: { [weak self] data in
                guard let self else { return }
                updateState(currentState.copyWith(.ready, products: data))
            })
            .disposed(by: bag)
    }
    
    func logout() {
        securityRepository.logout()
    }
}
