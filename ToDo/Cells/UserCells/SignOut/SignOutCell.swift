//
//  SignOutCell.swift
//  ToDo
//
//  Created by Vladimir Sekerko on 31.08.2022.
//

import UIKit

class SignOutCell: UITableViewCell {

    @IBOutlet weak var mainButton: UIButton!
    private var indexCell: Int!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func mainButtonAction(_ sender: UIButton) {
        print(indexCell == 0 ? "Выйти" : "Удалить")
    }
    
    func configure(index: Int) {
        mainButton.setTitle(index == 0 ? "Выйти" : "Удалить учетную запись", for: .normal)
        indexCell = index
    }
}
