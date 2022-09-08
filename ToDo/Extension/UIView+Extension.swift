//
//  UIView+Extension.swift
//  ToDo
//
//  Created by Vladimir Sekerko on 08.09.2022.
//

import Foundation
import UIKit

extension UIView {
    func cornerAndShadow(cornerRadius: CGFloat, shadowRadius: CGFloat, shadowOffset: CGSize) {
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowRadius = shadowRadius
        self.layer.shadowOpacity = 0.35
        self.layer.shadowOffset = shadowOffset
    }
}
