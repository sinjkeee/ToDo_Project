//
//  ImageViewController.swift
//  ToDo
//
//  Created by Vladimir Sekerko on 29.08.2022.
//

import UIKit

class ImageViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    var imageData: Data!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.image = UIImage(data: imageData)
    }
}
