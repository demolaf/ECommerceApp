//
//  LoginViewController.swift
//  ECommerceApp
//
//  Created by Ademola Fadumo on 20/06/2025.
//

import UIKit
import DefaultTextField
import RxSwift
import RxCocoa

class LoginViewController: UIViewController {
    private var scrollView: UIScrollView!
    private var contentView: UIView!
    private var emailTextField: DefaultTextField!
    private var passwordTextField: DefaultTextField!
    private var loginButton: DefaultButton!
    private var signupButton: UILabel!
    
    weak var coordinator: AuthCoordinator?
    let viewModel: LoginViewModel
    let bag = DisposeBag()
    
    init(viewModel: LoginViewModel) {
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
        setupLoginButton()
        setupSignupButton()
    }
    
    private func initializeViewAppearance() {
        title = "Login"
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
        
        emailTextField.formValidState
            .subscribe(onNext: { [weak self] isValid in
                guard let self else { return }
                debugPrint("emailTextField - isValid: \(isValid)")
            })
            .disposed(by: bag)
    }
    
    private func setupPasswordTextField() {
        passwordTextField = DefaultTextField(
            textFieldComponent: .init(
                title: "Password",
                hint: "Enter your password",
                obscured: true,
                validateWhenEmpty: true,
                validations: [
                    FormValidators.notEmpty(label: "Password")
                ]
            ))
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(passwordTextField)
        
        NSLayoutConstraint.activate([
            passwordTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            passwordTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 16),
        ])
        
        passwordTextField.formValidState
            .subscribe(onNext: { [weak self] isValid in
                guard let self else { return }
                debugPrint("passwordTextField - isValid: \(isValid)")
            })
            .disposed(by: bag)
    }
    
    private func setupLoginButton() {
        loginButton = DefaultButton()
        loginButton.button.setTitle("Login", for: .normal)
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(loginButton)
        
        NSLayoutConstraint.activate([
            loginButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            loginButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 48),
        ])
    }
    
    private func setupSignupButton() {
        signupButton = UILabel()
        signupButton.isUserInteractionEnabled = true
        signupButton.textAlignment = .center
        signupButton.attributedText = NSAttributedString(
            string: "Don't have an account? Signup",
            attributes: [
                .underlineStyle: NSUnderlineStyle.single.rawValue,
            ]
        )
        signupButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(signupButtonTapped)))
        signupButton.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(signupButton)
        
        NSLayoutConstraint.activate([
            signupButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            signupButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            signupButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 36),
            signupButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
    
    @objc private func signupButtonTapped() {
        debugPrint("signupButtonTapped")
        coordinator?.navigateToSignup()
    }
}
