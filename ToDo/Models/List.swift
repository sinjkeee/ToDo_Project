//
//  MainCell.swift
//  ToDo
//
//  Created by Vladimir Sekerko on 09.08.2022.
//

import Foundation
import UIKit

class List {
    var name: String
    var image: String
    var imageColor: UIColor
    var tasks: Int?
    
    init(name: String, image: String, imageColor: UIColor, countTask: Int?) {
        self.name = name
        self.image = image
        self.imageColor = imageColor
        self.tasks = countTask
    }
}
