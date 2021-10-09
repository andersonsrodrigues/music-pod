//
//  LoginWorker.swift
//  MusicPod
//
//  Created by Anderson Soares Rodrigues on 26/03/20.
//  Copyright (c) 2020 Anderson Soares Rodrigues. All rights reserved.
//

import UIKit

class LoginWorker {
    func openLoginAuthorizeOnSafari() {
        do {
            let url = try Constant.Server.authorizeURL.asURL()
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } catch {
            fatalError("There was not possible to open the url")
        }
    }
    
    func requestTokenFromServer(completion: @escaping(Bool, Error?) -> Void) {
        APIClient.requestTokens { (result, error) in
            completion(result,error)
        }
    }
}
