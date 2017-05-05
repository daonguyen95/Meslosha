//
//  MLSLoadingViewController.swift
//  Meslosha
//
//  Created by VAN DAO on 5/3/17.
//  Copyright © 2017 VAN DAO. All rights reserved.
//

import Foundation
import UIKit

class MLSLoadingViewController : UIViewController {
    
    var activityIndicatorView : UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        self.activityIndicatorView = UIActivityIndicatorView.init(activityIndicatorStyle: .gray)
        self.activityIndicatorView.frame = CGRect.init(x: screenWidth/2 - 25, y: screenHeight/2 - 25, width: 50, height: 50)
        self.activityIndicatorView.center = self.view.center
        self.view.addSubview(self.activityIndicatorView)
        
        self.activityIndicatorView.startAnimating()
//        [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! MLSLoginViewController
        self.navigationController?.pushViewController(loginViewController, animated: true)
        self.navigationController?.viewControllers.removeFirst()
        self.dismiss(animated: false, completion: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        print("Loading View Controller Disappeared")
    }
}
