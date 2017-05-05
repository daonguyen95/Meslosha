//
//  MLSMessViewController.swift
//  Meslosha
//
//  Created by VAN DAO on 5/3/17.
//  Copyright © 2017 VAN DAO. All rights reserved.
//

import Foundation
import UIKit

class MLSMessViewController : UIViewController {
    
    @IBOutlet var tableView: MLSMessTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib.init(nibName: "MLSMessTableViewCell", bundle: nil), forCellReuseIdentifier: "MessTableViewCell")
    }
    
    @IBAction func backTouchUpInside(_ sender: Any) {
        self.navigationController!.popViewController(animated: true)
    }
}

extension MLSMessViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessTableViewCell", for: indexPath) as! MLSMessTableViewCell
        cell.userName.text = "Name \(indexPath.row)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}

extension MLSMessViewController: UITableViewDelegate {
    
}


