//
//  ColorCell.swift
//  ToDo
//
//  Created by Vladimir Sekerko on 02.09.2022.
//

import UIKit
import SnapKit

class ColorCell: UICollectionViewCell {
    
    private lazy var colorView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemRed
        view.layer.cornerRadius = 15
        return view
    }()
    
    private lazy var subView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 6
        view.isHidden = true
        return view
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.addSubview(colorView)
        colorView.addSubview(subView)
        setConstraint()
    }

    func configure(color: UIColor) {
        colorView.backgroundColor = color
    }
    
    private func setConstraint() {
        colorView.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
        
        subView.snp.makeConstraints { make in
            make.width.height.equalTo(12)
            make.centerX.centerY.equalToSuperview()
        }
    }
}
