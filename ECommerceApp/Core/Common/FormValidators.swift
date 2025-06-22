//
//  FormValidators.swift
//  ECommerceApp
//
//  Created by Ademola Fadumo on 20/06/2025.
//

import Foundation
import DefaultTextField

struct FormValidators {
    static let email = FormValidator(
        message: "Email is not valid",
        validate: { input in
            guard let input else { return false }
            let pattern = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
            let predicate = NSPredicate(format: "SELF MATCHES %@", pattern)
            return predicate.evaluate(with: input)
        }
    )
    
    static func greaterThanZero(label: String) -> FormValidator {
        return FormValidator(
            message: "\(label) must be greater than zero",
            validate: { input in
                guard let input else { return false }
                return (Double(input) ?? 0) > 0
            }
        )
    }
    
    static let url = FormValidator(
        message: "URL is not valid",
        validate: { input in
            guard let input else { return false }
            let pattern = #"^(https?|ftp)://[^\s/$.?#].[^\s]*$"#
            let predicate = NSPredicate(format: "SELF MATCHES %@", pattern)
            return predicate.evaluate(with: input)
        }
    )
    
    static func notEmpty(label: String) -> FormValidator {
        return FormValidator(
            message: "\(label) cannot be empty",
            validate: { input in
                guard let input else { return false }
                return !input.isEmpty
            }
        )
    }
    
    static func confirmPassword(password: @autoclosure @escaping () -> String) -> FormValidator {
        return FormValidator(
            message: "Password is not the same",
            validate: { input in
                guard let input else { return false }
                return input == password()
            }
        )
    }
    
    static let atLeast8Characters = FormValidator(
        message: "Must be at least 8 characters long",
        validate: { input in
            guard let input else { return false }
            let pattern = ".{8,}"
            let predicate = NSPredicate(format: "SELF MATCHES %@", pattern)
            return predicate.evaluate(with: input)
        }
    )
    
    static let uppercaseAndLowercase = FormValidator(
        message: "Must contain both uppercase and lowercase letters",
        validate: { input in
            guard let input else { return false }
            let pattern = "^(?=.*[A-Z])(?=.*[a-z]).*$"
            let predicate = NSPredicate(format: "SELF MATCHES %@", pattern)
            return predicate.evaluate(with: input)
        }
    )
    
    static let numberAndSymbol = FormValidator(
        message: "Must contain a number and a special symbol",
        validate: { input in
            guard let input else { return false }
            let pattern = "^(?=.*\\d)(?=.*[#?!@$%^&*\\-]).*$"
            let predicate = NSPredicate(format: "SELF MATCHES %@", pattern)
            return predicate.evaluate(with: input)
        }
    )
}
