//
//  DefaultTextField.swift
//  ECommerceApp
//
//  Created by Ademola Fadumo on 20/06/2025.
//

import UIKit
import RxSwift
import RxCocoa

class DefaultTextField: UIView {
    struct TextFieldComponent {
        let title: String
        let hint: String
        var islabelHidden: Bool = false
        var enabled: Bool = true
        var obscured: Bool = false
        var maintainsValidationMessages: Bool = true
        var showsIconValidationMessage: Bool = false
        let validations: [FormValidators.FormValidator]
    }
    
    private var contentVStack: UIStackView!
    private(set) var label: UILabel!
    private(set) var textField: UITextField!
    private var obscureButton: UIButton!
    private var validationsVStack: UIStackView!
    
    private(set) var textFieldComponent: TextFieldComponent
    
    let textEditingValue = BehaviorRelay<String>(value: "")
    let textFieldValidValue = PublishRelay<Bool>()
    
    let bag = DisposeBag()
    
    init(textFieldComponent: TextFieldComponent) {
        self.textFieldComponent = textFieldComponent
        super.init(frame: .zero)
        setupContentVStack()
        setupLabel()
        setupTextField()
        setupObscureButton()
        setupValidationsVStack()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setupContentVStack() {
        contentVStack = UIStackView()
        contentVStack.axis = .vertical
        contentVStack.spacing = 8
        contentVStack.alignment = .fill
        contentVStack.distribution = .fill
        contentVStack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(contentVStack)
        
        NSLayoutConstraint.activate([
            contentVStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentVStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentVStack.topAnchor.constraint(equalTo: topAnchor),
            contentVStack.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    private func setupLabel() {
        label = UILabel()
        label.text = textFieldComponent.title
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .label
        label.isHidden = textFieldComponent.islabelHidden
        
        contentVStack.addArrangedSubview(label)
    }
    
    private func setupTextField() {
        textField = UITextField()
        textField.defaultTextAttributes = [
            .font: UIFont.systemFont(ofSize: 14)
        ]
        textField.leftViewMode = .always
        textField.rightViewMode = .always
        textField.leftView = UIView(frame: .init(x: 0, y: 0, width: 16, height: 0))
        textField.layer.borderColor = UIColor.systemGray3.cgColor
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 10
        textField.attributedPlaceholder = NSAttributedString(
            string: textFieldComponent.hint,
            attributes: [
                .font: UIFont.systemFont(ofSize: 14)
            ])
        textField.autocapitalizationType = .none
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        contentVStack.addArrangedSubview(textField)
        
        NSLayoutConstraint.activate([
            textField.heightAnchor.constraint(equalToConstant: 44),
        ])
        
        textField.rx.text.orEmpty
            .bind(to: textEditingValue)
            .disposed(by: bag)
        
        textField.isSecureTextEntry = textFieldComponent.obscured
    }
    
    private func setupObscureButton() {
        let button = UIButton(type: .custom)
        button.tintColor = .label
        button.setImage(UIImage(systemName: "eye"), for: .normal)
        button.addTarget(self, action: #selector(obscureButtonTapped), for: .primaryActionTriggered)
        
        let padding: CGFloat = 32
        let container = UIView(frame: CGRect(x: 0, y: 0, width: button.intrinsicContentSize.width + padding, height: button.intrinsicContentSize.height))
        button.frame = CGRect(x: padding / 2, y: 0, width: button.intrinsicContentSize.width, height: button.intrinsicContentSize.height)
        container.addSubview(button)
        
        textField.rightView = container
        textField.rightViewMode = .always
        
        obscureButton = button
        obscureButton.isHidden = !textFieldComponent.obscured
    }
    
    private func setupValidationsVStack() {
        validationsVStack = UIStackView()
        validationsVStack.axis = .vertical
        validationsVStack.spacing = 4
        validationsVStack.alignment = .fill
        validationsVStack.distribution = .fill
        
        contentVStack.addArrangedSubview(validationsVStack)
        
        // Validate Form
        textEditingValue
            .subscribe(onNext: { [weak self] text in
                self?.validateForm(input: text)
            })
            .disposed(by: bag)
    }
    
    private func validateForm(input: String) {
        // Animate removal of old validation views
        UIView.animate(withDuration: 0.25, animations: {
            self.validationsVStack.arrangedSubviews.forEach { view in
                view.alpha = 0
            }
        }, completion: { _ in
            // Now remove the views after fade out
            self.validationsVStack.arrangedSubviews.forEach {
                self.validationsVStack.removeArrangedSubview($0)
                $0.removeFromSuperview()
            }

            // Create new validation views
            self.textFieldComponent.validations.forEach { item in
                if let itemView = self.createItem(item: item, input: input) {
                    itemView.alpha = 0
                    self.validationsVStack.addArrangedSubview(itemView)
                    UIView.animate(withDuration: 0.25) {
                        itemView.alpha = 1
                    }
                }
            }
        })

        // Continue with isValid handling as before
        let isValid = textFieldComponent.validations.allSatisfy { $0.validate(input) }
        textFieldValidValue.accept(isValid)

        let textColor: UIColor
        let tintColor: UIColor
        let borderColor: UIColor

        if input.isEmpty {
            textColor = .label
            tintColor = .label
            borderColor = .systemGray3
        } else if isValid {
            textColor = .label
            tintColor = .label
            borderColor = .green
        } else {
            textColor = .red
            tintColor = .red
            borderColor = .red
        }

        // Animate text/tint
        UIView.transition(with: textField, duration: 0.25, options: .transitionCrossDissolve) {
            self.textField.textColor = textColor
        }
        UIView.transition(with: obscureButton, duration: 0.25, options: .transitionCrossDissolve) {
            self.obscureButton.tintColor = tintColor
        }

        // Animate borderColor
        let borderAnimation = CABasicAnimation(keyPath: "borderColor")
        borderAnimation.fromValue = textField.layer.borderColor
        borderAnimation.toValue = borderColor.cgColor
        borderAnimation.duration = 0.25
        textField.layer.add(borderAnimation, forKey: "borderColor")
        textField.layer.borderColor = borderColor.cgColor
    }
    
    private func createItem(item: FormValidators.FormValidator, input: String?) -> UIStackView? {
        guard let input, !input.isEmpty else {
            // Input is empty — do not show validation message
            return nil
        }

        let isValid = item.validate(input)

        // If valid and we're not meant to keep messages for valid cases, return nil
        if isValid && !textFieldComponent.maintainsValidationMessages {
            return nil
        }

        // Proceed to build the validation message
        let titleHStack = UIStackView()
        titleHStack.axis = .horizontal
        titleHStack.spacing = 4
        titleHStack.alignment = .center

        if textFieldComponent.showsIconValidationMessage {
            let iconName = isValid ? "checkmark.circle.fill" : "info.circle"
            let iconColor = isValid ? UIColor.systemGreen : UIColor.red
            
            let iconImage = UIImage(systemName: iconName)
            let iconView = UIImageView(image: iconImage)
            iconView.tintColor = iconColor
            iconView.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                iconView.widthAnchor.constraint(equalToConstant: 16),
                iconView.heightAnchor.constraint(equalToConstant: 16),
            ])
            
            titleHStack.addArrangedSubview(iconView)
        }
        
        let label = UILabel()
        label.text = item.message
        label.font = .systemFont(ofSize: 14)
        let textColor = isValid ? UIColor.systemGreen : UIColor.red
        label.textColor = textColor
        
        titleHStack.addArrangedSubview(label)

        return titleHStack
    }
    
    @objc private func obscureButtonTapped() {
        debugPrint("Obscure button tapped")
        toggleObscure()
    }
    
    func toggleObscure() {
        textFieldComponent.obscured.toggle()
        obscureButton.setImage(textFieldComponent.obscured ? UIImage(systemName: "eye.slash") : UIImage(systemName: "eye"), for: .normal)
        textField.isSecureTextEntry = textFieldComponent.obscured
    }
}
