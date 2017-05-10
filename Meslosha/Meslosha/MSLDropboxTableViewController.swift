//
//  MSLDropboxTableViewController.swift
//  Meslosha
//
//  Created by Welcome on 5/6/17.
//  Copyright © 2017 VAN DAO. All rights reserved.
//

import UIKit
import SwiftyDropbox
import Photos

class MSLDropboxTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var dropboxTableView: UITableView!
    
    @IBOutlet weak var addFileButton: UIBarButtonItem!
    var fileName : Array<String>?
    var dropboxItems = [DropboxItem]()
    var curDirectory : DropboxItem?
    
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var imagePicker = UIImagePickerController()
    var pickedImage = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Sing in Dropbox
        if DropboxClientsManager.authorizedClient == nil {
            DropboxClientsManager.authorizeFromController(UIApplication.shared,
                                                          controller: self,
                                                          openURL: { (url: URL) -> Void in
                                                            UIApplication.shared.openURL(url)
            })
            
        }
        
        //for root directory
        if curDirectory == nil {
            curDirectory = DropboxItem(coreItem: nil, isFolder: true, path: "")
        }
        
        //Get dropbox
        self.fileName = []
        
        if let client = DropboxClientsManager.authorizedClient{
            
            //client.deleteDropboxFiles()
            client.initClient(appDelegate.synedFileIDs)
            if let parentDir = curDirectory {
                self.listingDropboxFiles(parentDir, dropboxClient: client)
            }
        }
        
        imagePicker.delegate = self
        
    }
    
    // MARK - helper func
    fileprivate func setMessageLabel(_ messageLabel: UILabel, frame: CGRect, text: String, textColor: UIColor, numberOfLines: Int, textAlignment: NSTextAlignment, font: UIFont) {
        messageLabel.frame = frame
        messageLabel.text = text
        messageLabel.textColor = textColor
        messageLabel.numberOfLines = numberOfLines
        messageLabel.textAlignment = textAlignment
        messageLabel.font = font
        messageLabel.sizeToFit()
    }

    fileprivate func setCellWithDropboxContent(_ cell: MLSDropboxTableViewCell, fileName name: String) {
        
        cell.thumbnailImageView.image = UIImage.init(named: "file-icon")
        cell.titleLabel.text = name
    }

    fileprivate func createNoDataMessageView() -> Void {
        let messageLabel: UILabel = UILabel()
        
        setMessageLabel(messageLabel, frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height), text: "No data is currently available.", textColor: UIColor.black, numberOfLines: 0, textAlignment: NSTextAlignment.center, font: UIFont(name:"Palatino-Italic", size: 20)!)
        
        self.dropboxTableView.backgroundView = messageLabel
        self.dropboxTableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
        return
    }
    
    
    
}

//TableViewController Functions
extension MSLDropboxTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dropboxItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier: String = "DropboxTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! MLSDropboxTableViewCell
        
        setCellWithDropboxContent(cell, fileName: self.dropboxItems[indexPath.row].coreItem.name)
        
        
        return cell

    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            print("delete pressed")
        }
        
        let sync = UITableViewRowAction(style: .normal, title: "Sync") { (action, indexPath) in
            print("sync pressed")
            
            let client = DropboxClientsManager.authorizedClient
            
            if client != nil{
                client?.downloadDropboxFile(self.dropboxItems[indexPath.row], completionHandlerForDownLoadFile: { (success, error) in
                    
                    if success {
                        self.appDelegate.synedFileIDs.append(self.dropboxItems[indexPath.row].id)
                        print("\(self.dropboxItems[indexPath.row].coreItem.name) is saved")
                    }
                })
            }
        }
        
        sync.backgroundColor = UIColor.blue
        
        if appDelegate.synedFileIDs.contains(self.dropboxItems[indexPath.row].id) {
            return  [delete]
        }
        
        return [delete, sync]
    }
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if self.dropboxItems[indexPath.row].isFolder == true {
        
            let folderVC = storyboard?.instantiateViewController(withIdentifier: "DropboxTableViewController") as! MSLDropboxTableViewController
            folderVC.curDirectory = DropboxItem(coreItem: nil, isFolder: true, parent: self.curDirectory, fileType: nil, path: (self.curDirectory?.path)! + "/" + self.dropboxItems[indexPath.row].coreItem.name)
            self.navigationController?.pushViewController(folderVC, animated: true)
            
        } else if appDelegate.synedFileIDs.contains(dropboxItems[indexPath.row].id){
                
            if let client = DropboxClientsManager.authorizedClient {
                
                let detailVC = storyboard?.instantiateViewController(withIdentifier: "DropboxFileDetail") as! DropboxFileDetailViewController
                
                detailVC.data = client.loadFileDataFromDatabase(self.dropboxItems[indexPath.row])
                self.navigationController?.pushViewController(detailVC, animated: true)
                
            }
        }
        
    }
    
    
    
}   

// Dropbox functions usage
extension MSLDropboxTableViewController {
    
    func listingDropboxFiles(_ parentDir: DropboxItem, dropboxClient client: DropboxClient) {
        client.getListFilesByPath(folderPath: parentDir.path, parent: parentDir, conpletionHandlerForListingDopboxFiles: { (result, error) in
            
            guard error == nil else {
                print("There was error when get list files by the given path: \(parentDir.path)")
                return
            }
            
            self.dropboxItems = result as! [DropboxItem]
            
            if self.dropboxItems.count == 0 {
                self.createNoDataMessageView()
            } else {
            
                DispatchQueue.main.async {
                    self.dropboxTableView.reloadData()
                    
                }
            }
            
        })
    }
}

//Image picker
extension MSLDropboxTableViewController  {
    
    @IBAction func addButtonTapped(_ sender: Any) {
        
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        pickedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        var fileName: String = ""
        
        if let imageURL = info[UIImagePickerControllerReferenceURL] as? URL {
            let result = PHAsset.fetchAssets(withALAssetURLs: [imageURL], options: nil)
            let asset = result.firstObject
            fileName = asset?.value(forKey: "filename") as! String
            
        }
        
        if let client = DropboxClientsManager.authorizedClient {
            
            let data = UIImagePNGRepresentation(pickedImage)! as Data
            client.uploadFile(data, fileName, currentFoler: curDirectory!, completionHanderForUploadFile: { (success, error) in
                
                var alert: UIAlertController
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .default)
                    
                if success {
                    alert = UIAlertController(title: "Dropbox uploader", message: "File uploaded successful", preferredStyle: .alert)
                    
                    
                    
                } else {
                    alert = UIAlertController(title: "Dropbox uploader", message: "File upload unsuccessful", preferredStyle: .alert)
                }
                
                alert.addAction(cancelAction)
                self.present(alert, animated: true)
                
            })
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
}
