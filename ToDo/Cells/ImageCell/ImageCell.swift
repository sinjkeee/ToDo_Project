//
//  ImageCell.swift
//  ToDo
//
//  Created by Vladimir Sekerko on 28.08.2022.
//

import UIKit
import SnapKit

protocol ImageCellDelegate: AnyObject {
    func shareImage(image: UIImage)
    func deleteImage(index: Int)
}

class ImageCell: UICollectionViewCell {
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.backgroundColor = .systemBlue
        return imageView
    }()
    
    private lazy var deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "multiply"), for: .normal)
        button.addTarget(self, action: #selector(deleteImageTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var shareButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        button.addTarget(self, action: #selector(shareImageTapped), for: .touchUpInside)
        return button
    }()
    
    weak var delegate: ImageCellDelegate?
    private var image: UIImage!
    private var index: Int!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.addSubview(imageView)
        contentView.addSubview(deleteButton)
        contentView.addSubview(shareButton)
        backgroundColor = .white
        setConstraint()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.cornerAndShadow(cornerRadius: 6,
                             shadowRadius: 6,
                             shadowOffset: CGSize(width: 5, height: 8))
    }

    @objc private func deleteImageTapped() {
        delegate?.deleteImage(index: index)
    }
    
    @objc private func shareImageTapped() {
        delegate?.shareImage(image: image)
    }
    
    private func setConstraint() {
        deleteButton.snp.makeConstraints { make in
            make.width.height.equalTo(20)
            make.trailing.equalToSuperview().inset(8)
            make.bottom.equalToSuperview().inset(8)
        }
        
        shareButton.snp.makeConstraints { make in
            make.width.height.equalTo(20)
            make.leading.equalToSuperview().inset(8)
            make.bottom.equalToSuperview().inset(8)
        }
        
        imageView.snp.makeConstraints { make in
            make.top.trailing.leading.equalToSuperview().inset(8)
            make.bottom.equalToSuperview().inset(32)
        }
    }
    
    func configure(withData data: Data, index: Int) {
        image = UIImage(data: data)
        self.index = index
        imageView.image = UIImage(data: data)
    }
}

struct ImageCellConstants {
    static let leftDistanceToView: CGFloat = 40
    static let rightDistanceToView: CGFloat = 40
    static let galleryMinimumLineSpacing: CGFloat = 10
    static let galleryItemWidth = (UIScreen.main.bounds.width - ImageCellConstants.leftDistanceToView - ImageCellConstants.rightDistanceToView - (ImageCellConstants.galleryMinimumLineSpacing / 2)) / 2
}
