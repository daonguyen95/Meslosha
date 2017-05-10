//
//  DropboxItem.swift
//  Meslosha
//
//  Created by Welcome on 5/6/17.
//  Copyright © 2017 VAN DAO. All rights reserved.
//

import Foundation
import SwiftyDropbox

public struct FileExtensions {
    
    public static let docExtensions = ["pdf", "docx", "docm", "dotx", "dotm", "docb", "doc", "dot" ]
    public static let excelExtensions = ["xls", "xlt", "xlm", "csv"]
    public static let powerpointExtensions = ["ppt", "pot", "pps", "pptx"]
    public static let imageExtensions = ["png", "jpg", "jpeg", "gif", "bmp"]
    public static let videoExtensions = ["mp4", "wmv", "mov", "avi"]
    public static let audioExtentions = ["mp3", "wav", "wma"]
    
}

public enum FileType {
    case doc
    case image
    case audio
    case video
    case undefined
}

public class DropboxItem: NSObject {
    
    var id: String!
    var coreItem: Files.Metadata!
    var isFolder: Bool!
    var path: String!
    var fileType: FileType?
    var isSynced: Bool?
    
    var parent: DropboxItem?
    
    init(coreItem: Files.Metadata?, isFolder: Bool, path: String) {
        self.coreItem = coreItem
        self.isFolder = isFolder
        self.path = path
    }
    
    init(coreItem: Files.Metadata?, isFolder: Bool, parent: DropboxItem?, fileType: FileType?, path: String) {
        
        self.coreItem = coreItem
        self.parent = parent
        self.isFolder = isFolder
        self.fileType = fileType
        self.path = path
    }
    
     
}
