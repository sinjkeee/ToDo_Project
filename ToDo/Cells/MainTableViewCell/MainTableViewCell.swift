//
//  MainTableViewCell.swift
//  ToDo
//
//  Created by Vladimir Sekerko on 09.08.2022.
//

import UIKit

class MainTableViewCell: UITableViewCell {

    @IBOutlet weak var imageCell: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
    
    func customCell(with cell: List) {
        imageCell.image = UIImage(systemName: cell.image)
        imageCell.tintColor = cell.imageColor
        nameLabel.text = cell.name
        guard let tasks = cell.tasks else { return }
        countLabel.text = "\(tasks)"
    }
}
