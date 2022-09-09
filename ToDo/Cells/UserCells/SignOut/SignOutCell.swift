//
//  SignOutCell.swift
//  ToDo
//
//  Created by Vladimir Sekerko on 31.08.2022.
//

import UIKit
import Firebase

class SignOutCell: UITableViewCell {

    @IBOutlet weak var mainButton: UIButton!
    private var indexCell: Int!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    private func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print(error)
        }
    }
    
    private func deleteCurrentUser() {
        let user = Auth.auth().currentUser

        user?.delete { error in
            if error != nil {
                print(error?.localizedDescription as Any)
          } else {
            // Account deleted.
          }
        }
    }
    
    @IBAction func mainButtonAction(_ sender: UIButton) {
        indexCell == 0 ? signOut() : deleteCurrentUser()
    }
    
    func configure(index: Int) {
        mainButton.setTitle(index == 0 ? "Sign Out".localized() : "Delete Account".localized(), for: .normal)
        indexCell = index
    }
}
