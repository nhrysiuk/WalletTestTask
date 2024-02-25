//
//  Additional.swift
//  WalletTestTask
//
//  Created by Анастасія Грисюк on 25.02.2024.
//

import Foundation
import UIKit

extension UIColor {
    static var turquoise: UIColor {
        return UIColor(red: 104/255, green: 222/255, blue: 228/255, alpha: 1.0)
    }
}

enum Category: String, CaseIterable {
    case groceries
    case taxi
    case electronics
    case restaurant
    case other
}

enum Const {
    static let dateFormat = "dd.MM.yyyy"
    
}
