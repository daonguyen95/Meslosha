//
//  UIImage+extension.swift
//  Meslosha
//
//  Created by VAN DAO on 5/4/17.
//  Copyright © 2017 VAN DAO. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics

extension UIImage {
    
    func resizeImage(newWidth: CGFloat) -> UIImage? {
        
        let scale = newWidth / self.size.width
        let newHeight = self.size.height * scale
        UIGraphicsBeginImageContext(CGSize.init(width: newWidth, height: newHeight))
        self.draw(in: CGRect.init(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
