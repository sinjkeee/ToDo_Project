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
    
    func custonCell(with cell: MainCell) {
        imageCell.image = UIImage(systemName: cell.image)
        imageCell.tintColor = cell.imageColor
        nameLabel.text = cell.name
    }
}
