//
//  LoginRouter.swift
//  MusicPod
//
//  Created by Anderson Soares Rodrigues on 26/03/20.
//  Copyright (c) 2020 Anderson Soares Rodrigues. All rights reserved.
//

import UIKit

@objc protocol LoginRoutingLogic {
    func routeToHome(segue: UIStoryboardSegue?)
}

class LoginRouter: NSObject, LoginRoutingLogic {
    weak var viewController: LoginViewController?
    
    // MARK: Routing
    
    func routeToHome(segue: UIStoryboardSegue?) {
        if let segue = segue {
            viewController?.performSegue(withIdentifier: segue.identifier!, sender: viewController.self)
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let destinationVC = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
            navigateToHome(source: viewController!, destination: destinationVC)
        }
    }
    
    // MARK: Navigation
    
    func navigateToHome(source: LoginViewController, destination: HomeViewController) {
        source.show(destination, sender: nil)
    }
}
