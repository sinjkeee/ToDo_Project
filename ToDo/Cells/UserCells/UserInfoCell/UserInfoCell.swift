//
//  UserInfoCell.swift
//  ToDo
//
//  Created by Vladimir Sekerko on 31.08.2022.
//

import UIKit

protocol UserInfoCellDelegate: AnyObject {
    func showAlert()
}

class UserInfoCell: UITableViewCell {
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userEmailLabel: UILabel!
    
    weak var delegate: UserInfoCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        userImageView.layer.cornerRadius = userImageView.frame.height / 2
        userImageView.clipsToBounds = true
        
        let recognizer = UITapGestureRecognizer(target: self,
                                                action: #selector(imageTapped))
        userImageView.isUserInteractionEnabled = true
        userImageView.addGestureRecognizer(recognizer)
    }

    @objc private func imageTapped() {
        delegate?.showAlert()
    }
    
    func configure(with user: UserModel) {
        userNameLabel.text = user.name
        userEmailLabel.text = user.uid
        userImageView.image = user.userImage.isEmpty ? UIImage(systemName: "person.circle") : UIImage(data: user.userImage)
    }
}
