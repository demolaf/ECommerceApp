//
//  AmountTextField.swift
//  ECommerceApp
//
//  Created by Ademola Fadumo on 22/06/2025.
//

import UIKit
import DefaultTextField
import RxSwift

class AmountTextField: DefaultTextField {
    var amountEditingState: Observable<Double?> {
        textEditingState
            .compactMap { $0 }
            .map { Double($0) }
    }
}
