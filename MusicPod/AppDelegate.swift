//
//  AppDelegate.swift
//  MusicPod
//
//  Created by Anderson Soares Rodrigues on 26/03/20.
//  Copyright © 2020 Anderson Soares Rodrigues. All rights reserved.
//

import UIKit

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    // MARK: Functions

    func checkIfFirstLaunch() {
        if !UserDefaults.standard.bool(forKey: "HasLaunchedBefore") {
            UserDefaults.standard.set(true, forKey: "HasLaunchedBefore")
            UserDefaults.standard.set(nil, forKey: "accessToken")
            UserDefaults.standard.set(nil, forKey: "refreshToken")
            UserDefaults.standard.set(nil, forKey: "expireToken")
            UserDefaults.standard.synchronize()
        } else {
            let accessToken = UserDefaults.standard.object(forKey: "accessToken")
            let refreshToken = UserDefaults.standard.object(forKey: "refreshToken")
            
            if let accessToken = accessToken, let refreshToken = refreshToken {
                Constant.Auth.accessToken = accessToken as? String
                Constant.Auth.refreshToken = refreshToken as? String
            }
        }
    }
    
    // MARK: UIApplicationDelegate

    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Usually this is not overridden. Using the "did finish launching" method is more typical
        checkIfFirstLaunch()

        return true
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        DataController.shared.load()
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        saveContext()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        saveContext()
    }
    
    // MARK: - UIApplication URL
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        // Process the URL.
        guard let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true),
            let scheme = components.scheme,
            let params = components.queryItems else {
                fatalError("Invalid URL or album path missing")
                return false
        }
        
        if scheme != "musicpodapp" {
            fatalError("Invalid scheme")
            return false
        }
        
        if let sourceCode = params.first(where: { $0.name == "code" })?.value {
            Constant.Auth.authorizationToken = sourceCode
            let loginVC = window?.rootViewController as! LoginViewController
            _ = loginVC.requestTokenOnExternal()
            
            return true
        } else {
            return false
        }
    }

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = DataController.shared.viewContext
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

