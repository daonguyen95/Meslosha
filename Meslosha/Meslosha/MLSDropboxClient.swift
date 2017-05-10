//
//  DropboxClient.swift
//  Meslosha
//
//  Created by Welcome on 5/7/17.
//  Copyright © 2017 VAN DAO. All rights reserved.
//

import Foundation
import SwiftyDropbox
import CoreData



extension DropboxClient {
    
    
    
    func initClient(_ synedFileIDs: [String]) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        if #available(iOS 10.0, *) {
            let managedContext = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "DropboxFile")
            
            do {
                let objects = try managedContext.fetch(fetchRequest)
                
                for object in objects {
                    let managedObj = object as! NSManagedObject
                    appDelegate.synedFileIDs.append(managedObj.value(forKey: "id") as! String)
                }
            } catch let error as NSError {
                print("Could not delete. \(error), \(error.userInfo)")
            }
        } else {
            // Fallback on earlier versions
            print("error: cannot run in orlder than iOS 10.0 version")
        }
        
    }
    
    //private functions
    
    private func getDataWithCompletionHandlerForListingDropboxFiles(_ data: Files.ListFolderResult, path: String, parentItem: DropboxItem, completionForParseData: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        var dropboxItems = [DropboxItem]()
        
        for entry in data.entries {
            
            let item = DropboxItem(coreItem: entry, isFolder: true, path: path)
            
            item.parent = parentItem
            
            item.id = SerializeUtil.prepareJSONForSerialization(Files.MetadataSerializer().serialize(entry))["id"] as! String
            
            let name = entry.name as NSString
            if  name.pathExtension != "" {
                
                item.path = item.path + "/" + (name as String)
                item.isFolder = false
                
                if FileExtensions.audioExtentions.contains(name.pathExtension) {
                    item.fileType = .audio
                } else if FileExtensions.docExtensions.contains(name.pathExtension) {
                    item.fileType = .doc
                } else if FileExtensions.excelExtensions.contains(name.pathExtension) {
                    item.fileType = .doc
                } else if FileExtensions.imageExtensions.contains(name.pathExtension) {
                    item.fileType = .image
                } else if FileExtensions.powerpointExtensions.contains(name.pathExtension) {
                    item.fileType = .doc
                } else if FileExtensions.videoExtensions.contains(name.pathExtension){
                    item.fileType = .video
                } else {
                    item.fileType = .undefined
                }
            }
            
            
            dropboxItems.append(item)
        }
        
        completionForParseData(dropboxItems as AnyObject?, nil)
    }
    
    
    private func saveDataWithCompletionHandlerForDownloadDropboxFile (_ data: Data?, _ path: String?, _ id: String, completionForSaveData: (_ success: Bool, _ error: NSError?) -> Void) {
        
        guard let data = data, let path = path else {
            completionForSaveData(false, NSError(domain: "saveDataWhenDownloadDropboxFile", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not save data"]))
            return
        }
        
        self.save(data: data, path, id)
        completionForSaveData(true, nil)
        
    }
    
    
    private func save(data: Data, _ path: String, _ id: String) {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        // 1
        if #available(iOS 10.0, *) {
            let managedContext =
                appDelegate.persistentContainer.viewContext
            
            // 2
            let entity =
                NSEntityDescription.entity(forEntityName: "DropboxFile",
                                           in: managedContext)!
            
            let item = NSManagedObject(entity: entity,
                                         insertInto: managedContext)
            
            // 3
            item.setValue(data, forKeyPath: "data")
            item.setValue(path, forKey: "path")
            item.setValue(id, forKey: "id")
            
            
            // 4
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        } else {
            // Fallback on earlier versions
            print("error: cannot run in orlder than iOS 10.0 version")
        }
        
        
    }
    
    //public functions:
    
    public func getListFilesByPath(folderPath path: String, parent parentItem: DropboxItem, conpletionHandlerForListingDopboxFiles: @escaping(_ data: AnyObject?, _ error: NSError?) -> Void ) {
        
        if let client = DropboxClientsManager.authorizedClient {
            
            client.files.listFolder(path: path).response(completionHandler: { (response, error) in
                
                for data in (response?.entries)! {
                    print(data.name)
                }
                
                guard error == nil else{
                    
                    print("There was error when donload file from dropbox: \(error)")
                    return
                }
                
                guard let data = response else {
                    print("There was no data from dropbox download file")
                    return
                }
                
                self.getDataWithCompletionHandlerForListingDropboxFiles(data, path: path, parentItem: parentItem, completionForParseData: conpletionHandlerForListingDopboxFiles)
            })
            
        }
        
        
    }
    
    public func downloadDropboxFile(_ item: DropboxItem, completionHandlerForDownLoadFile: @escaping(_ success: Bool, _ error: NSError?) -> Void ){
        let client = DropboxClientsManager.authorizedClient
        
        if client != nil{
            //let destURL = directoryURL.appendingPathComponent((fileNam)
            let destination: (URL, HTTPURLResponse) -> URL = { temporaryURL, response in
                let fileManager = FileManager.default
                let directoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
                // generate a unique name for this file in case we've seen it before
                //let UUID = Foundation.UUID().uuidString
                let pathComponent = item.path
                return directoryURL.appendingPathComponent(pathComponent!)
                
            }
            client?.files.download(path: item.path, overwrite: true, destination: destination)
                .response { response, error in
                    if let (metadata, url) = response {
                        if let data = try? Data(contentsOf: url) {
                            print("Dowloaded file name: \(metadata.name)")
                            
                            self.saveDataWithCompletionHandlerForDownloadDropboxFile(data, item.path, item.id, completionForSaveData: completionHandlerForDownLoadFile)
                        }
                    } else if let error = error {
                        print(error)
                        self.saveDataWithCompletionHandlerForDownloadDropboxFile(nil, nil, "", completionForSaveData: completionHandlerForDownLoadFile)
                    }
                }
                .progress { progressData in
                    print(progressData)
            }
        }
    }

    public func uploadFile(_ data: Data, _ fileName: String, currentFoler curDir: DropboxItem, completionHanderForUploadFile: @escaping(_ success: Bool, _ error: NSError?) -> Void) {
        
        self.files.upload(path: curDir.path + "/" + fileName + ".png", input: data)
            .response { response, error in
                
                guard error == nil else {
                    print(error ?? "There was error when upload file")
                    
                    completionHanderForUploadFile(false, NSError(domain: (error?.description)!, code: 1, userInfo: [NSLocalizedDescriptionKey: "There was error when upload file"]))
                    return
                }
                
                guard response != nil else {
                    print("There was no response when upload file")
                    
                    return
                }
                
                completionHanderForUploadFile(true, nil)
            }
            .progress { progressData in
                print(progressData)
        }
        
    }
    
    public func deleteDropboxFiles() {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        // 1
        if #available(iOS 10.0, *) {
            let managedContext =
                appDelegate.persistentContainer.viewContext
            
            // 2
            let entity =
                NSEntityDescription.entity(forEntityName: "DropboxFile",
                                           in: managedContext)!
            
            // 3
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity.name!)
           
            
            // 4
            do {
                let objects  = try managedContext.fetch(fetchRequest)
                for object in objects {
                    managedContext.delete(object as! NSManagedObject)
                }
                print("whole data were deleted completly")
            } catch let error as NSError {
                print("Could not delete. \(error), \(error.userInfo)")
            }
        } else {
            // Fallback on earlier versions
            print("error: cannot run in orlder than iOS 10.0 version")
        }

    }
    
    public func loadFileDataFromDatabase(_ item: DropboxItem) -> Data? {
        
        var res: Data?
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return res
        }
        
        if #available(iOS 10.0, *) {
            let managedContext = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "DropboxFile")
            
            do {
                let objects = try managedContext.fetch(fetchRequest)
                
                for object in objects {
                    
                    let managedObj = object as! NSManagedObject
                    if managedObj.value(forKey: "id") as! String == item.id {
                        res = managedObj.value(forKey: "data") as? Data
                    }
                }
            } catch let error as NSError {
                print("Could not delete. \(error), \(error.userInfo)")
            }
        } else {
            // Fallback on earlier versions
            print("error: cannot run in orlder than iOS 10.0 version")
        }
        
        return res
    }
    
    
}
