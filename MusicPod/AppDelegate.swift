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
                K.Auth.accessToken = accessToken as? String
                K.Auth.refreshToken = refreshToken as? String
            }
        }
    }
    
    // MARK: UIApplicationDelegate

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        checkIfFirstLaunch()
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // MARK: - UIApplication URL
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        // Determine who sent the URL.
        let sendingAppID = options[.sourceApplication]
        print("source application = \(sendingAppID ?? "Unknown")")
        
        // Process the URL.
        guard let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true),
            let scheme = components.scheme,
            let sourcePath = components.path,
            let params = components.queryItems else {
                print("Invalid URL or album path missing")
                return false
        }
        
        if scheme != "musicpodapp" {
            print("Invalid scheme")
            return false
        }
        
        if let sourceCode = params.first(where: { $0.name == "code" })?.value {
            print("sourcePath = \(sourcePath)")
            print("code = \(sourceCode)")
            
            K.Auth.authorizationToken = sourceCode
            let loginVC = window?.rootViewController as! LoginViewController
            _ = loginVC.requestTokenOnExternal()
            
            return true
        } else {
            print("Data index missing")
            return false
        }
    }

}

