//
//  String+Extension.swift
//  ToDo
//
//  Created by Vladimir Sekerko on 08.09.2022.
//

import Foundation

extension String {
    func localized() -> String {
        return NSLocalizedString(self, comment: "")
    }
}
