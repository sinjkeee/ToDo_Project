//
//  Extension+UIViewController.swift
//  ToDo
//
//  Created by Vladimir Sekerko on 15.08.2022.
//

import Foundation
import UIKit
import Firebase

extension UIViewController {
    func showActionSheet(title: String?, message: String?, showCancel: Bool, actions: [UIAlertAction]) {
        
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .actionSheet)
        
        for action in actions {
            alertController.addAction(action)
        }
        
        if showCancel {
            alertController.addAction(UIAlertAction(title: "Cancel".localized(),
                                                    style: .cancel))
        }
        
        present(alertController, animated: true)
    }
    
    func showAlert(title: String?, message: String?, showCancel: Bool, actions: [UIAlertAction]) {
        
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        
        for action in actions {
            alertController.addAction(action)
        }
        
        if showCancel {
            alertController.addAction(UIAlertAction(title: "Cancel".localized(),
                                                    style: .cancel))
        }
        
        present(alertController, animated: true)
    }
    
    func handleError(_ error: Error) {
        if let errorCode = AuthErrorCode.Code(rawValue: error._code) {
            print(errorCode.errorMessage)
            let alert = UIAlertController(title: "Error!".localized(),
                                          message: errorCode.errorMessage,
                                          preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok",
                                         style: .default,
                                         handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true)
        }
    }
}
