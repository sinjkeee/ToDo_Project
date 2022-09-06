//
//  ListCell.swift
//  ToDo
//
//  Created by Vladimir Sekerko on 06.09.2022.
//

import UIKit

class ListCell: UITableViewCell {

    @IBOutlet weak var listImage: UIImageView!
    @IBOutlet weak var listName: UILabel!
    @IBOutlet weak var switchList: UISwitch!
    private var indexCell: Int!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        listImage.tintColor = UIColor(red: 100/255, green: 149/255, blue: 237/255, alpha: 1)
    }

    func configure(index: Int) {
        indexCell = index
        switch index {
        case 0:
            listName.text = "Важно"
            listImage.image = UIImage(systemName: "star")
        case 1:
            listName.text = "Запланировано"
            listImage.image = UIImage(systemName: "calendar")
        case 2:
            listName.text = "Завершенные"
            listImage.image = UIImage(systemName: "checkmark.circle")
        case 3:
            listName.text = "Задачи"
            listImage.image = UIImage(systemName: "text.badge.checkmark")
        default:
            break
        }
    }
    
    @IBAction func switchListAction(_ sender: UISwitch) {
        
    }
    
}
