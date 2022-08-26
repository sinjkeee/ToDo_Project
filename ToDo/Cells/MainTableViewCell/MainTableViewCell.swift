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
    
    func customCell(with cell: ListModel) {
        imageCell.image = UIImage(systemName: cell.index.image)
        imageCell.tintColor = cell.index.color
        nameLabel.text = cell.index == .custom ? cell.name : cell.index.name
        countLabel.text = "\(cell.tasks.filter({ $0.isCompleted == false }).count)"
    }
}
