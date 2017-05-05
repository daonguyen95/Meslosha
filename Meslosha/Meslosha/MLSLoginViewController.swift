//
//  MLSLoginViewController.swift
//  Meslosha
//
//  Created by VAN DAO on 5/3/17.
//  Copyright © 2017 VAN DAO. All rights reserved.
//

import UIKit
import FBSDKLoginKit
//import GoogleSignIn
//import GoogleToolboxForMac

class MLSLoginViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if FBSDKAccessToken.current() != nil{
            //fetchUserData()
        }
        
//        if (GIDSignIn.sharedInstance().currentUser != nil) {
//            _ = GIDSignIn.sharedInstance().currentUser.authentication.accessToken
//            // Use accessToken in your URL Requests Header
//        }
//        
//        var error: NSError?
//        GGLContext.sharedInstance().configureWithError(&error)
//        
//        if error != nil{
//            print(error!)
//            return
//        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        print("Login View Controller Disappeared")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func loginFBTouchUpInside(_ sender: Any) {
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager.loginBehavior = .systemAccount
        
        fbLoginManager.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if (error == nil){
                let fbloginresult : FBSDKLoginManagerLoginResult = result!
                
                if fbloginresult.grantedPermissions != nil {
                    if(fbloginresult.grantedPermissions.contains("email"))
                    {
                        self.getFBUserData()
                    }
                }
            }
        }
    }
    
    @IBAction func loginGIDTouchUpInside(_ sender: Any) {
//        GIDSignIn.sharedInstance().uiDelegate = self
//        GIDSignIn.sharedInstance().delegate = self
//        GIDSignIn.sharedInstance().signIn()
    }
    
//    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
//        if error != nil{
//            print(error)
//            return
//        }
//        
//        let mapViewController = self.storyboard?.instantiateViewController(withIdentifier: "MapViewController") as! MLSMapViewController
//        
//        self.navigationController?.pushViewController(mapViewController, animated: true)
//    }


    @IBAction func loginTouchUpInside(_ sender: Any) {
        let mapViewController = self.storyboard?.instantiateViewController(withIdentifier: "MapViewController") as! MLSMapViewController

        self.navigationController?.pushViewController(mapViewController, animated: true)
        self.navigationController?.viewControllers.removeFirst()
        self.dismiss(animated: false, completion: nil)
    }
    
    func getFBUserData(){
        if((FBSDKAccessToken.current()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    
                    DispatchQueue.main.async {
//                        UserDefaults.standard.setValue(self.dict, forKey: "currentUser")
                        
                        let mapViewController = self.storyboard?.instantiateViewController(withIdentifier: "MapViewController") as! MLSMapViewController
                        
                        self.navigationController?.pushViewController(mapViewController, animated: true)
                        self.navigationController?.viewControllers.removeFirst()
                        self.dismiss(animated: false, completion: nil)
                    }
                }
            })
        }
    }
}

