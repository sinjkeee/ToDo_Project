//
//  Extension+UIViewController.swift
//  ToDo
//
//  Created by Vladimir Sekerko on 15.08.2022.
//

import Foundation
import UIKit

extension UIViewController {
    func showActionSheet(title: String?, message: String?, showCancel: Bool, actions: [UIAlertAction]) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        for action in actions {
            alertController.addAction(action)
        }
        
        if showCancel {
            alertController.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        }
        
        present(alertController, animated: true)
    }
}
