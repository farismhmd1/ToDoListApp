//
//  AppDelegate.swift
//  ToDoList
//
//  Created by Apple on 11/27/18.
//  Copyright © 2018 Faris. All rights reserved.
//

import UIKit
import CoreData
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // Initialize Googgle sign-in
        GIDSignIn.sharedInstance().clientID = Constants.googleClientID
        GIDSignIn.sharedInstance().delegate = self
        
        // Check Login status and Show login or home screen
        self.window = UIWindow(frame: UIScreen.main.bounds)
        if UserDefaults.standard.bool(forKey: Constants.userDefaultsKey.isLoginSkipped) {
            loadHomeVC()
        } else {
            // Google Auth check
            if GIDSignIn.sharedInstance()?.hasAuthInKeychain() ?? false {
                print("Signed in")
                loadHomeVC()
            } else {
                print("Not signed in")
                loadLoginVC()
            }
        }
        self.window?.makeKeyAndVisible()
        return true
    }
    
    func loadHomeVC() {
        let VC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ToDoListViewController") as! ToDoListViewController
        let navigationVC = UINavigationController(rootViewController: VC)
        self.window?.rootViewController = navigationVC
        
    }
    func loadLoginVC() {
        let VC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        self.window?.rootViewController = VC
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "ToDoList")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}
//MARK:- Google Delegate set up
extension AppDelegate: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print("\(error.localizedDescription)")
            NotificationCenter.default.post(
                name: Notification.Name(rawValue: Constants.NSNotificationName.GoogleAuthNotification), object: nil, userInfo: ["status": Constants.GoogleSingInStatus.failure])
        } else {
            // Perform any operations on signed in user here.
            //let userId = user.userID                  // For client-side use only!
            //let idToken = user.authentication.idToken // Safe to send to the server
            //let fullName = user.profile.name
            //let givenName = user.profile.givenName
            //let familyName = user.profile.familyName
            //let email = user.profile.email
            NotificationCenter.default.post(
                name: Notification.Name(rawValue: Constants.NSNotificationName.GoogleAuthNotification),
                object: nil,
                userInfo: ["status": Constants.GoogleSingInStatus.success])
        }
    }
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url as URL?,
                                                 sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                                                 annotation: options[UIApplication.OpenURLOptionsKey.annotation])
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
              withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        NotificationCenter.default.post(
            name: Notification.Name(rawValue: Constants.NSNotificationName.GoogleAuthNotification),
            object: nil,
            userInfo: ["status": Constants.GoogleSingInStatus.disconnected])
    }
}

