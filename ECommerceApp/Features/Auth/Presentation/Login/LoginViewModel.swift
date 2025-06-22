//
//  LoginViewModel.swift
//  ECommerceApp
//
//  Created by Ademola Fadumo on 20/06/2025.
//

import Foundation
import RxSwift
import RxRelay
import RxCocoa

struct LoginState: Equatable {
    enum ViewState: Equatable {
        case initial
        case loading
        case ready
        case authenticate
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
    ) -> LoginState {
        var newState = LoginState()
        newState.viewState = viewState
        newState.processingState = processingState ?? self.processingState
        newState.formValid = formValid ?? self.formValid
        newState.email = email ?? self.email
        newState.password = password ?? self.password
        newState.failureMessage = failureMessage ?? self.failureMessage
        return newState
    }
}

class LoginViewModel {
    init(state: LoginState = .init(), securityRepository: SecurityRepository) {
        self._state = .init(value: state)
        self.securityRepository = securityRepository
        
        updateState(state.copyWith(.initial))
    }
    
    private let _state: BehaviorRelay<LoginState>
    private let securityRepository: SecurityRepository
    
    var state: Driver<LoginState> {
        _state
            .distinctUntilChanged()
            .asDriver(onErrorDriveWith: .empty())
    }
    
    var currentState: LoginState {
        _state.value
    }
    
    private func updateState(_ state: LoginState) {
        if currentState == state { return }
        self._state.accept(state)
    }
    
    let emailTextPublisher = PublishRelay<String?>()
    let emailValidPublisher = PublishRelay<Bool>()
    
    let passwordTextPublisher = PublishRelay<String?>()
    let passwordValidPublisher = PublishRelay<Bool>()
    
    private let bag = DisposeBag()
    
    func initialize() {
        validateForm()
    }
    
    private func validateForm() {
        Observable.combineLatest(emailValidPublisher, passwordValidPublisher)
            .map { $0.0 && $0.1 }
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
    
    func login() async {
        updateState(currentState.copyWith(.authenticate, processingState: .processing))
        let result = await securityRepository.login(email: currentState.email ?? "", password: currentState.password ?? "")
        switch result {
        case .success(let user):
            DefaultLogger.log(self, "User - \(user)")
            updateState(currentState.copyWith(.authenticate, processingState: .success))
        case .failure(let error):
            updateState(currentState.copyWith(.authenticate, processingState: .failure, failureMessage: error.localizedDescription))
        }
    }
}
