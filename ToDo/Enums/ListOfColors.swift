//
//  ListOfColors.swift
//  ToDo
//
//  Created by Vladimir Sekerko on 03.09.2022.
//

import Foundation
import RealmSwift
import UIKit

enum ListOfColors: Int, PersistableEnum, CaseIterable {
    case one = 1, two = 2, three = 3, four = 4, five = 5, six = 6, seven = 7, eight = 8, nine = 9, ten = 10, eleven = 11, twelve = 12, thirteen = 13
    
    var color: UIColor {
        switch self {
        case .one:
            return UIColor(red: 255/255, green: 192/255, blue: 203/255, alpha: 1)
        case .two:
            return UIColor(red: 250/255, green: 92/255, blue: 92/255, alpha: 1)
        case .three:
            return UIColor(red: 216/255, green: 191/255, blue: 216/255, alpha: 1)
        case .four:
            return UIColor(red: 255/255, green: 204/255, blue: 0/255, alpha: 1)
        case .five:
            return UIColor(red: 100/255, green: 149/255, blue: 237/255, alpha: 1)
        case .six:
            return UIColor(red: 204/255, green: 119/255, blue: 34/255, alpha: 1)
        case .seven:
            return UIColor.systemCyan
        case .eight:
            return UIColor.systemGray
        case .nine:
            return UIColor.systemMint
        case .ten:
            return UIColor.systemGreen
        case .eleven:
            return UIColor.systemIndigo
        case .twelve:
            return UIColor.systemOrange
        case .thirteen:
            return UIColor.systemTeal
        }
    }
}
