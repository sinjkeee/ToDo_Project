//
//  MainCell.swift
//  ToDo
//
//  Created by Vladimir Sekerko on 09.08.2022.
//

import Foundation
import UIKit

class MainCell {
    var name: String
    var image: String
    var imageColor: UIColor
    
    init(name: String, image: String, imageColor: UIColor) {
        self.name = name
        self.image = image
        self.imageColor = imageColor
    }
}
