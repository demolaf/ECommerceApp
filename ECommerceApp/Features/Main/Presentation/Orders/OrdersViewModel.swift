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
    var failureMessage: String?
    
    func copyWith(
        _ viewState: ViewState,
        processingState: ProcessingState? = nil,
        failureMessage: String? = nil
    ) -> OrdersState {
        var newState = OrdersState()
        newState.viewState = viewState
        newState.processingState = processingState ?? self.processingState
        newState.failureMessage = failureMessage ?? self.failureMessage
        return newState
    }
}

class OrdersViewModel {
    init(state: OrdersState = .init()) {
        self._state = .init(value: state)
        
        updateState(state.copyWith(.initial))
    }
    
    
    private let _state: BehaviorRelay<OrdersState>
    
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
    
    func initialize() {}
}
