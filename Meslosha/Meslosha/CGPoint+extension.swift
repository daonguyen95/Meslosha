//
//  CGPoint+extension.swift
//  Meslosha
//
//  Created by VAN DAO on 5/4/17.
//  Copyright © 2017 VAN DAO. All rights reserved.
//

import Foundation
import CoreGraphics

extension CGPoint {
    func distance(toPoint point: CGPoint) -> CGFloat {
        return (self.x - point.x) * (self.x - point.x) + (self.y - point.y) * (self.y - point.y)
    }
}
