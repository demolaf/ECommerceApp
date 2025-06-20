//
//  FormValidators.swift
//  ECommerceApp
//
//  Created by Ademola Fadumo on 20/06/2025.
//

import Foundation

struct FormValidators {
    
    struct FormValidator {
        let message: String
        let validate: (String?) -> Bool
    }
    
    static let email = FormValidator(
        message: "Email is not valid",
        validate: { input in
            guard let input else { return false }
            let pattern = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
            let predicate = NSPredicate(format: "SELF MATCHES %@", pattern)
            return predicate.evaluate(with: input)
        }
    )

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
