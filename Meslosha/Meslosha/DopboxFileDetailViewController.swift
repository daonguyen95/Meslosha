//
//  DopboxFileDetailViewController.swift
//  Meslosha
//
//  Created by Welcome on 5/8/17.
//  Copyright © 2017 VAN DAO. All rights reserved.
//

import Foundation
import UIKit

class DropboxFileDetailViewController: UIViewController {
    
    var data: Data?
    
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let data = data {
            self.imageView.image = UIImage(data: data)
        }
    }
}
