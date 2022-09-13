//
//  AuthErrorCode+Extension.swift
//  ToDo
//
//  Created by Vladimir Sekerko on 09.09.2022.
//

import Foundation
import Firebase

extension AuthErrorCode.Code {
    var errorMessage: String {
        switch self {
        case .wrongPassword:
            return "Your password is incorrect.".localized()
        case .emailAlreadyInUse:
            return "The email is already in use with another account.".localized()
        case .userNotFound:
            return "Account not found for the specified user. Please check and try again.".localized()
        case .userDisabled:
            return "Your account has been disabled. Please contact support.".localized()
        case .invalidEmail, .invalidSender, .invalidRecipientEmail:
            return "Please enter a valid email.".localized()
        case .networkError:
            return "Network error. Please try again.".localized()
        case .weakPassword:
            return "Your password is too weak. The password must be 6 characters long or more.".localized()
        default:
            return "Unknown error occurred".localized()
        }
    }
}
