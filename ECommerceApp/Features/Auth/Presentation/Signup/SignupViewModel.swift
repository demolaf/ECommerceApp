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
        case register
        case error
    }
    
    var viewState: ViewState = .initial
    var processingState: ProcessingState?
    var formValid: Bool = false
    var email: String?
    var password: String?
    var failureMessage: String?
    
    func copyWith(
        _ viewState: ViewState,
        processingState: ProcessingState? = nil,
        formValid: Bool? = nil,
        email: String? = nil,
        password: String? = nil,
        failureMessage: String? = nil
    ) -> SignupState {
        var newState = SignupState()
        newState.viewState = viewState
        newState.processingState = processingState ?? self.processingState
        newState.formValid = formValid ?? self.formValid
        newState.email = email ?? self.email
        newState.password = password ?? self.password
        newState.failureMessage = failureMessage ?? self.failureMessage
        return newState
    }
}

class SignupViewModel {
    init(state: SignupState = .init(), securityRepository: SecurityRepository) {
        self._state = .init(value: state)
        self.securityRepository = securityRepository
        
        updateState(state.copyWith(.initial))
    }
    
    
    private let _state: BehaviorRelay<SignupState>
    private let securityRepository: SecurityRepository
    
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
    
    let emailTextPublisher = PublishRelay<String?>()
    let emailValidPublisher = PublishRelay<Bool>()
    
    let passwordTextPublisher = PublishRelay<String?>()
    let passwordValidPublisher = PublishRelay<Bool>()
    
    let confirmPasswordTextPublisher = PublishRelay<String?>()
    let confirmPasswordValidPublisher = PublishRelay<Bool>()
    
    private let bag = DisposeBag()
    
    func initialize() {
        validateForm()
    }
    
    private func validateForm() {
        Observable.combineLatest(emailValidPublisher, passwordValidPublisher, confirmPasswordValidPublisher)
            .map { $0.0 && $0.1 && $0.2 }
            .subscribe(onNext: { [weak self] isValid in
                guard let self else { return }
                updateState(currentState.copyWith(.initial, formValid: isValid))
            })
            .disposed(by: bag)
        
        emailTextPublisher
            .subscribe(onNext: { [weak self] text in
                guard let self else { return }
                updateState(currentState.copyWith(.initial, email: text))
            })
            .disposed(by: bag)
        
        passwordTextPublisher
            .subscribe(onNext: { [weak self] text in
                guard let self else { return }
                updateState(currentState.copyWith(.initial, password: text))
            })
            .disposed(by: bag)
    }
    
    func signup() async {
        updateState(currentState.copyWith(.register, processingState: .processing))
        let result = await securityRepository.signup(email: currentState.email ?? "", password: currentState.password ?? "")
        switch result {
        case .success(let user):
            DefaultLogger.log(self, "User - \(user)")
            updateState(currentState.copyWith(.register, processingState: .success))
        case .failure(let error):
            updateState(currentState.copyWith(.register, processingState: .failure, failureMessage: error.localizedDescription))
        }
    }
}
