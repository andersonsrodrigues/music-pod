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
            let url = try K.Server.authorizeURL.asURL()
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } catch {
            fatalError("There was not possible to open the url")
        }
    }
    
    func requestTokenFromServer(completion: @escaping(Bool, Error?) -> Void) {
        APIClient.performRequest(router: APIRouter.authorizationCode, responseType: Token.self) { response in
            switch response {
            case .success(let value):
                K.Auth.accessToken = value.accessToken
                K.Auth.refreshToken = value.refreshToken
                
                UserDefaults.standard.set(value.accessToken, forKey: "accessToken")
                UserDefaults.standard.set(value.refreshToken, forKey: "refreshToken")
                
                return completion(true, nil)
            case .failure(let error):
                return completion(false, error)
            }
        }
    }
    
    func hasLoggedIn(completion: @escaping(Bool, Error?) -> Void) {
        APIClient.performRequest(router: APIRouter.refreshCode, responseType: Token.self) { response in
            switch response {
            case .success(let value):
                K.Auth.accessToken = value.accessToken
                
                UserDefaults.standard.set(value.accessToken, forKey: "accessToken")
                
                return completion(true, nil)
            case .failure(let error):
                return completion(false, error)
            }
        }
    }
}
