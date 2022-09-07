//
//  Sorting.swift
//  ToDo
//
//  Created by Vladimir Sekerko on 07.09.2022.
//

import Foundation
import RealmSwift

enum Sorting: Int, PersistableEnum {
    case alphabet = 1
    case isImportant
    case dateOfCreation
    case dateOfCompletion
}
