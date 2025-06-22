//
//  AddProductViewController.swift
//  ECommerceApp
//
//  Created by Ademola Fadumo on 22/06/2025.
//

import UIKit
import DefaultTextField
import RxSwift
import RxCocoa
import Kingfisher

class AddProductViewController: UIViewController {
    private var scrollView: UIScrollView!
    private var contentView: UIView!
    private var photoImageView: UIImageView!
    private var photoUrlTextField: DefaultTextField!
    private var nameTextField: DefaultTextField!
    private var priceTextField: AmountTextField!
    private var addProductButton: DefaultButton!
    
    weak var coordinator: MainCoordinator?
    
    let viewModel: AddProductViewModel
    let bag = DisposeBag()
    
    init(viewModel: AddProductViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeViewAppearance()
        setupScrollView()
        setupPhotoImageView()
        setupPhotoUrlTextField()
        setupNameTextField()
        setupPriceTextField()
        setupAddProductButton()
        subscribeToViewModel()
    }
    
    private func initializeViewAppearance() {
        title = "Add Product"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .systemBackground
    }
    
    private func setupScrollView() {
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func setupPhotoImageView() {
        photoImageView = UIImageView()
        photoImageView.kf.indicatorType = .activity
        photoImageView.image = UIImage(named: "placeholder-image")
        photoImageView.clipsToBounds = true
        photoImageView.layer.cornerRadius = 8
        photoImageView.contentMode = .scaleAspectFill
        photoImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(photoImageView)
        
        NSLayoutConstraint.activate([
            photoImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            photoImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            photoImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            photoImageView.heightAnchor.constraint(equalToConstant: 200)
        ])
        
        viewModel.photoUrlPublisher
            .subscribe(onNext: { [weak self] urlString in
                guard let self else { return }
                if let urlString, !urlString.isEmpty {
                    photoImageView.kf.setImage(with: URL(string: urlString), placeholder: UIImage(named: "placeholder-image"))
                }
            })
            .disposed(by: bag)
    }
    
    private func setupPhotoUrlTextField() {
        photoUrlTextField = DefaultTextField(
            textFieldComponent: .init(
                title: "Photo URL",
                hint: "Enter a valid URL",
                validations: [
                    FormValidators.url
                ]
            ))
        photoUrlTextField.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(photoUrlTextField)
        
        NSLayoutConstraint.activate([
            photoUrlTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            photoUrlTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            photoUrlTextField.topAnchor.constraint(equalTo: photoImageView.bottomAnchor, constant: 24),
        ])
        
        photoUrlTextField.textEditingState
            .bind(to: viewModel.photoUrlPublisher)
            .disposed(by: bag)
        
        photoUrlTextField.formValidState
            .bind(to: viewModel.photoUrlValidPublisher)
            .disposed(by: bag)
    }
    
    private func setupNameTextField() {
        nameTextField = DefaultTextField(
            textFieldComponent: .init(
                title: "Name",
                hint: "Enter a name",
                validateWhenEmpty: true,
                validations: [
                    FormValidators.notEmpty(label: "Name")
                ]
            ))
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nameTextField)
        
        NSLayoutConstraint.activate([
            nameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            nameTextField.topAnchor.constraint(equalTo: photoUrlTextField.bottomAnchor, constant: 8),
        ])
        
        nameTextField.textEditingState
            .bind(to: viewModel.nameTextPublisher)
            .disposed(by: bag)
        
        nameTextField.formValidState
            .bind(to: viewModel.nameValidPublisher)
            .disposed(by: bag)
    }
    
    private func setupPriceTextField() {
        priceTextField = AmountTextField(
            textFieldComponent: .init(
                title: "Price",
                hint: "Enter a price",
                keyboardType: .decimalPad,
                validations: [
                    FormValidators.greaterThanZero(label: "Price")
                ]
            ))
        priceTextField.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(priceTextField)
        
        NSLayoutConstraint.activate([
            priceTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            priceTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            priceTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 8),
            priceTextField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
        
        priceTextField.amountEditingState
            .compactMap { $0 }
            .bind(to: viewModel.pricePublisher)
            .disposed(by: bag)
        
        priceTextField.formValidState
            .bind(to: viewModel.priceValidPublisher)
            .disposed(by: bag)
    }
    
    private func setupAddProductButton() {
        addProductButton = DefaultButton()
        addProductButton.isEnabled = false
        addProductButton.button.setTitle("Add", for: .normal)
        addProductButton.button.addTarget(self, action: #selector(addButtonTapped), for: .primaryActionTriggered)
        addProductButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(addProductButton)
        
        NSLayoutConstraint.activate([
            addProductButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            addProductButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            addProductButton.topAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 24),
            addProductButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
        ])
        
        viewModel.state
            .distinctUntilChanged(\.formValid)
            .drive(onNext: { [weak self] state in
                guard let self else { return }
                addProductButton.isEnabled = state.formValid
            })
            .disposed(by: bag)
    }
    
    private func subscribeToViewModel() {
        viewModel.state
            .do(onNext: { [weak self] state in
                guard let self else { return }
                if state.viewState == .addProduct {
                    if state.processingState == .success {
                        coordinator?.router.pop()
                    }
                }
            })
            .drive(onNext: { state in
                LoadingOverlay.hide()
                
                switch state.viewState {
                case .loading:
                    LoadingOverlay.show()
                case .addProduct:
                    if state.processingState == .failure {
                        Toast.show(type: .error, message: state.failureMessage ?? "")
                    }
                    
                    if state.processingState == .processing {
                        LoadingOverlay.show()
                    }
                    
                    if state.processingState == .success {
                        Toast.show(type: .success, message: "Added Product Successfully")
                    }
                case .error:
                    break
                default:
                    break
                }
            })
            .disposed(by: bag)
        
        viewModel.initialize()
    }
    
    @objc private func addButtonTapped() {
        Task {
            await viewModel.addProduct()
        }
    }
}
