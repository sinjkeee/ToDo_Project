//
//  ListIndex.swift
//  ToDo
//
//  Created by Vladimir Sekerko on 16.08.2022.
//

import Foundation
import RealmSwift
import UIKit

enum ListIndex: Int, PersistableEnum {
    case one = 1
    case two = 2
    case three = 3
    case four = 4
    case five = 5
    case custom
    
    var name: String {
        switch self {
        case .one:
            return "Мой день"
        case .two:
            return "Важно"
        case .three:
            return "Запланировано"
        case .four:
            return "Завершенные"
        case .five:
            return "Задачи"
        case .custom:
            return "Новый список"
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
