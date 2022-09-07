//
//  ListCell.swift
//  ToDo
//
//  Created by Vladimir Sekerko on 06.09.2022.
//

import UIKit

protocol ListCellDelegate: AnyObject {
    func changeListVisibility(index: Int)
}

class ListCell: UITableViewCell {
    
    @IBOutlet weak var listImage: UIImageView!
    @IBOutlet weak var listName: UILabel!
    @IBOutlet weak var switchList: UISwitch!
    weak var delegate: ListCellDelegate?
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
            let importantList = RealmManager.shared.realm.objects(ListModel.self).first { list in
                list.index == ListIndex.two
            }
            guard let importantList = importantList else { return }
            switchList.isOn = !importantList.isHidden
        case 1:
            listName.text = "Запланировано"
            listImage.image = UIImage(systemName: "calendar")
            let dateOfCompletedList = RealmManager.shared.realm.objects(ListModel.self).first { list in
                list.index == ListIndex.three
            }
            guard let dateOfCompletedList = dateOfCompletedList else { return }
            switchList.isOn = !dateOfCompletedList.isHidden
        case 2:
            listName.text = "Завершенные"
            listImage.image = UIImage(systemName: "checkmark.circle")
            let completedTasks = RealmManager.shared.realm.objects(ListModel.self).first { list in
                list.index == ListIndex.four
            }
            guard let completedTasks = completedTasks else { return }
            switchList.isOn = !completedTasks.isHidden
        default:
            listName.text = "Задачи"
            listImage.image = UIImage(systemName: "text.badge.checkmark")
            let tasksList = RealmManager.shared.realm.objects(ListModel.self).first { list in
                list.index == ListIndex.five
            }
            guard let tasksList = tasksList else { return }
            switchList.isOn = !tasksList.isHidden
        }
    }
    
    @IBAction func switchListAction(_ sender: UISwitch) {
        switch indexCell {
        case 0:
            self.delegate?.changeListVisibility(index: indexCell)
        case 1:
            self.delegate?.changeListVisibility(index: indexCell)
        case 2:
            self.delegate?.changeListVisibility(index: indexCell)
        default:
            self.delegate?.changeListVisibility(index: indexCell)
        }
    }
    
}
