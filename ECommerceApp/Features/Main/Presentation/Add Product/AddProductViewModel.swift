//
//  AddProductViewModel.swift
//  ECommerceApp
//
//  Created by Ademola Fadumo on 22/06/2025.
//

import Foundation
import RxSwift
import RxRelay
import RxCocoa

struct AddProductState: Equatable {
    enum ViewState: Equatable {
        case initial
        case loading
        case ready
        case addProduct
        case error
    }
    
    var viewState: ViewState = .initial
    var processingState: ProcessingState?
    var formValid: Bool = false
    var photoUrl: String?
    var name: String?
    var price: Double?
    var failureMessage: String?
    
    func copyWith(
        _ viewState: ViewState,
        processingState: ProcessingState? = nil,
        formValid: Bool? = nil,
        photoUrl: String? = nil,
        name: String? = nil,
        price: Double? = nil,
        failureMessage: String? = nil
    ) -> AddProductState {
        var newState = AddProductState()
        newState.viewState = viewState
        newState.processingState = processingState ?? self.processingState
        newState.formValid = formValid ?? self.formValid
        newState.photoUrl = photoUrl ?? self.photoUrl
        newState.name = name ?? self.name
        newState.price = price ?? self.price
        newState.failureMessage = failureMessage ?? self.failureMessage
        return newState
    }
}

class AddProductViewModel {
    init(state: AddProductState = .init(), productRepository: ProductRepository) {
        self._state = .init(value: state)
        self.productRepository = productRepository
        
        updateState(state.copyWith(.initial))
    }
    
    
    private let _state: BehaviorRelay<AddProductState>
    private let productRepository: ProductRepository
    
    var state: Driver<AddProductState> {
        _state
            .distinctUntilChanged()
            .asDriver(onErrorDriveWith: .empty())
    }
    
    var currentState: AddProductState {
        _state.value
    }
    
    private func updateState(_ state: AddProductState) {
        if currentState == state { return }
        self._state.accept(state)
    }
    
    let photoUrlPublisher = PublishRelay<String?>()
    let photoUrlValidPublisher = PublishRelay<Bool>()
    
    let nameTextPublisher = PublishRelay<String?>()
    let nameValidPublisher = PublishRelay<Bool>()
    
    let pricePublisher = PublishRelay<Double>()
    let priceValidPublisher = PublishRelay<Bool>()
    
    let bag = DisposeBag()
    
    func initialize() {
        validateForm()
    }
    
    func validateForm() {
        Observable.combineLatest(photoUrlValidPublisher, nameValidPublisher, priceValidPublisher)
            .map { $0.0 && $0.1 && $0.2 }
            .subscribe(onNext: { [weak self] isValid in
                guard let self else { return }
                updateState(currentState.copyWith(.initial, formValid: isValid))
            })
            .disposed(by: bag)
        
        photoUrlPublisher
            .subscribe(onNext: { [weak self] url in
                guard let self else { return }
                updateState(currentState.copyWith(.initial, photoUrl: url))
            })
            .disposed(by: bag)
        
        nameTextPublisher
            .subscribe(onNext: { [weak self] text in
                guard let self else { return }
                updateState(currentState.copyWith(.initial, name: text))
            })
            .disposed(by: bag)
        
        pricePublisher
            .subscribe(onNext: { [weak self] amount in
                guard let self else { return }
                updateState(currentState.copyWith(.initial, price: amount))
            })
            .disposed(by: bag)
    }
    
    func addProduct() async {
        updateState(currentState.copyWith(.addProduct, processingState: .processing))
        let product = Product(id: UUID(), photoUrl: currentState.photoUrl ?? "", name: currentState.name ?? "", price: currentState.price ?? 0)
        let result = await productRepository.storeProduct(product: product)
        switch result {
        case .success(let success):
            updateState(currentState.copyWith(.addProduct, processingState: .success))
        case .failure(let failure):
            updateState(currentState.copyWith(.addProduct, processingState: .failure))
        }
    }
}
