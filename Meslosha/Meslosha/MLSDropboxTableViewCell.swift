//
//  MSLDropboxTableViewCell.swift
//  Meslosha
//
//  Created by Welcome on 5/6/17.
//  Copyright © 2017 VAN DAO. All rights reserved.
//

import Foundation
import UIKit

public protocol MSLDropboxTableViewCellDelegate {
    
    /// delegate function will called when sync button is tapped
    ///
    /// - Parameters:
    ///   - tablevViewCell: MSL view table cell
    ///   - sender: sender
    func MSLDropboxTableViewCell(_ tablevViewCell: MLSDropboxTableViewCell, didTapSyncButton sender: Any)
    
    /// delegate function will called when delete button is tapped
    ///
    /// - Parameters:
    ///   - tablevViewCell: MSL view table cell
    ///   - sender: sender
    func MSLDropboxTableViewCell(_ tablevViewCell: MLSDropboxTableViewCell, didTapDeleteButton sender: Any)
    
}

public class MLSDropboxTableViewCell: UITableViewCell {
    @IBOutlet var view: UITableViewCell!
    
    
    public var delegate: MSLDropboxTableViewCellDelegate?
    
    @IBOutlet weak var titleLabel: UITextField!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        Bundle.main.loadNibNamed("MLSDropboxTableViewCell", owner: self, options: nil)
        
        self.addSubview(self.view)
    }
}
