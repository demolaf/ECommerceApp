//
//  SignupViewController.swift
//  ECommerceApp
//
//  Created by Ademola Fadumo on 20/06/2025.
//

import UIKit
import DefaultTextField
import RxSwift
import RxCocoa

class SignupViewController: UIViewController {
    private var scrollView: UIScrollView!
    private var contentView: UIView!
    private var emailTextField: DefaultTextField!
    private var passwordTextField: DefaultTextField!
    private var confirmPasswordTextField: DefaultTextField!
    private var signupButton: DefaultButton!
    private var loginButton: UILabel!
    
    weak var coordinator: AuthCoordinator?
    let viewModel: SignupViewModel
    let bag = DisposeBag()
    
    init(viewModel: SignupViewModel) {
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
        setupEmailTextField()
        setupPasswordTextField()
        setupConfirmPasswordTextField()
        setupSignupButton()
        setupLoginButton()
        subscribeToViewModel()
    }
    
    private func initializeViewAppearance() {
        title = "Signup"
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
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func setupEmailTextField() {
        emailTextField = DefaultTextField(
            textFieldComponent: .init(
                title: "Email",
                hint: "Enter your email",
                keyboardType: .emailAddress,
                validations: [
                    FormValidators.email
                ]
            ))
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(emailTextField)
        
        NSLayoutConstraint.activate([
            emailTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            emailTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            emailTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
        ])
        
        emailTextField.textEditingState
            .bind(to: viewModel.emailTextPublisher)
            .disposed(by: bag)
        
        emailTextField.formValidState
            .bind(to: viewModel.emailValidPublisher)
            .disposed(by: bag)
    }
    
    private func setupPasswordTextField() {
        passwordTextField = DefaultTextField(
            textFieldComponent: .init(
                title: "Password",
                hint: "Enter your password",
                obscured: true,
                maintainsValidationMessages: true,
                showsIconValidationMessage: true,
                validations: [
                    FormValidators.atLeast8Characters,
                    FormValidators.uppercaseAndLowercase,
                    FormValidators.numberAndSymbol,
                ]
            ))
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(passwordTextField)
        
        NSLayoutConstraint.activate([
            passwordTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            passwordTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 8),
        ])
        
        passwordTextField.textEditingState
            .bind(to: viewModel.passwordTextPublisher)
            .disposed(by: bag)
        
        passwordTextField.formValidState
            .bind(to: viewModel.passwordValidPublisher)
            .disposed(by: bag)
    }
    
    private func setupConfirmPasswordTextField() {
        confirmPasswordTextField = DefaultTextField(
            textFieldComponent: .init(
                title: "Confirm Password",
                hint: "Enter your password",
                obscured: true,
                validations: [
                    FormValidators.confirmPassword(password: self.passwordTextField.textValue ?? "")
                ]
            ))
        confirmPasswordTextField.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(confirmPasswordTextField)
        
        NSLayoutConstraint.activate([
            confirmPasswordTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            confirmPasswordTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            confirmPasswordTextField.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 16),
        ])
        
        passwordTextField.textEditingState
            .subscribe(onNext: { [weak self] text in
                self?.confirmPasswordTextField.revalidateIfNeeded()
            })
            .disposed(by: bag)
        
        confirmPasswordTextField.formValidState
            .bind(to: viewModel.confirmPasswordValidPublisher)
            .disposed(by: bag)
    }
    
    private func setupSignupButton() {
        signupButton = DefaultButton()
        signupButton.isEnabled = false
        signupButton.button.setTitle("Sign up", for: .normal)
        signupButton.button.addTarget(self, action: #selector(signupButtonTapped), for: .primaryActionTriggered)
        signupButton.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(signupButton)
        
        NSLayoutConstraint.activate([
            signupButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            signupButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            signupButton.topAnchor.constraint(equalTo: confirmPasswordTextField.bottomAnchor, constant: 48),
        ])
        
        viewModel.state
            .distinctUntilChanged(\.formValid)
            .drive(onNext: { [weak self] state in
                guard let self else { return }
                signupButton.isEnabled = state.formValid
            })
            .disposed(by: bag)
    }
    
    private func setupLoginButton() {
        loginButton = UILabel()
        loginButton.isUserInteractionEnabled = true
        loginButton.textAlignment = .center
        loginButton.attributedText = NSAttributedString(
            string: "Already have an account?",
            attributes: [
                .underlineStyle: NSUnderlineStyle.single.rawValue,
            ]
        )
        loginButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(loginButtonTapped)))
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(loginButton)
        
        NSLayoutConstraint.activate([
            loginButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            loginButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            loginButton.topAnchor.constraint(equalTo: signupButton.bottomAnchor, constant: 36),
            loginButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
    
    private func subscribeToViewModel() {
        viewModel.state
            .do(onNext: { [weak self] state in
                guard let self else { return }
                if state.viewState == .register {
                    if state.processingState == .success {
                        coordinator?.navigateToHome()
                    }
                }
            })
            .drive(onNext: { state in
                LoadingOverlay.hide()
                
                switch state.viewState {
                case .loading:
                    LoadingOverlay.show()
                case .register:
                    if state.processingState == .failure {
                        Toast.show(type: .error, message: state.failureMessage ?? "")
                    }
                    
                    if state.processingState == .processing {
                        LoadingOverlay.show()
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
    
    @objc private func signupButtonTapped() {
        Task {
            await viewModel.signup()
        }
    }
    
    @objc private func loginButtonTapped() {
        coordinator?.popToLogin()
    }
}
