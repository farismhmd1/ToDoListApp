//
//  LoginViewController.swift
//  ToDoList
//
//  Created by Apple on 11/27/18.
//  Copyright © 2018 Faris. All rights reserved.
//

import UIKit
import GoogleSignIn

class LoginViewController: UIViewController {
    
    @IBOutlet weak var signInButton: GIDSignInButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        GIDSignIn.sharedInstance().uiDelegate = self
    }
    
    //MARK:- Button Actions
    // User skipped login
    @IBAction func skipLoginButtonTapped(_ sender: Any) {
        // Set user defaults for skip authentication check on next launch
        UserDefaults.standard.set(true, forKey: Constants.userDefaultsKey.isLoginSkipped)
        UserDefaults.standard.synchronize()
        loadHomeScreen()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Add NSNotification Observer for checking GoogleAuth result
        NotificationCenter.default.addObserver(self, selector: #selector(handleNSNotification(_:)), name: NSNotification.Name(rawValue: Constants.NSNotificationName.GoogleAuthNotification), object: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
        // remove NSNotification Observer
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constants.NSNotificationName.GoogleAuthNotification), object: nil)
    }
    
    //MARK:- Other Methods
    func loadHomeScreen() {
        DispatchQueue.main.async {
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let VC = storyboard.instantiateViewController(withIdentifier: "ToDoListViewController") as! ToDoListViewController
            let navigationController = UINavigationController(rootViewController: VC)
            self.present(navigationController, animated: false, completion: nil)
        }
    }
    // Method for Handling NSNotification
    @objc func handleNSNotification(_ sender : Any) {
        if let notification = sender as? NSNotification {
            if let userInfo = notification.userInfo as? [String: Any] // or use if you know the type  [AnyHashable : Any]
            {
                print(userInfo)
                if let status = userInfo["status"] as? String {
                    if status == Constants.GoogleSingInStatus.success {
                        // Google login success
                        loadHomeScreen()
                    } else {
                        // Show error message
                        print("Login error")
                    }
                }
            }
        }
    }
}
//MARK:- Extensions
extension LoginViewController: GIDSignInUIDelegate {
}
