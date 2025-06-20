//
//  SignupViewModel.swift
//  ECommerceApp
//
//  Created by Ademola Fadumo on 20/06/2025.
//

import Foundation
import RxSwift
import RxRelay
import RxCocoa

struct SignupState: Equatable {
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
    ) -> SignupState {
        var newState = SignupState()
        newState.viewState = viewState
        newState.processingState = processingState ?? self.processingState
        newState.failureMessage = failureMessage ?? self.failureMessage
        return newState
    }
}

class SignupViewModel {
    init(state: SignupState = .init()) {
        self._state = .init(value: state)
        
        updateState(state.copyWith(.initial))
    }
    
    
    private let _state: BehaviorRelay<SignupState>
    
    var state: Driver<SignupState> {
        _state
            .distinctUntilChanged()
            .asDriver(onErrorDriveWith: .empty())
    }
    
    var currentState: SignupState {
        _state.value
    }
    
    private func updateState(_ state: SignupState) {
        if currentState == state { return }
        self._state.accept(state)
    }
    
    func initialize() {}
}
