//
//  ListIndex.swift
//  ToDo
//
//  Created by Vladimir Sekerko on 16.08.2022.
//

import Foundation
import RealmSwift
import UIKit

enum ListIndex: Int, PersistableEnum, CaseIterable {
    case one = 1
    case two = 2
    case three = 3
    case four = 4
    case five = 5
    case custom
    
    var name: String {
        switch self {
        case .one:
            return "My Day".localized()
        case .two:
            return "Important".localized()
        case .three:
            return "Planned".localized()
        case .four:
            return "Completed".localized()
        case .five:
            return "Tasks".localized()
        case .custom:
            return "New List".localized()
        }
    }
    
    var image: String {
        switch self {
        case .one:
            return "sun.max"
        case .two:
            return "star"
        case .three:
            return "calendar"
        case .four:
            return "checkmark.circle"
        case .five:
            return "text.badge.checkmark"
        case .custom:
            return "list.bullet"
        }
    }
    
    var color: UIColor {
        switch self {
        case .one:
            return .systemYellow
        case .two:
            return .systemBlue
        case .three:
            return .systemOrange
        case .four:
            return .systemRed
        case .five:
            return .systemGreen
        case .custom:
            return .systemPink
        }
    }
}
