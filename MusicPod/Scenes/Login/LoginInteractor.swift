//
//  LoginInteractor.swift
//  MusicPod
//
//  Created by Anderson Soares Rodrigues on 26/03/20.
//  Copyright (c) 2020 Anderson Soares Rodrigues. All rights reserved.
//

import UIKit

protocol LoginBusinessLogic {
    func requestLoginOnExternal(request: Login.Data.Request)
    func requestToken()
}

class LoginInteractor: LoginBusinessLogic {
    var presenter: LoginPresentationLogic?
    var worker = LoginWorker()
    var isLoggedIn = false
    
    // MARK: Do something
    
    func requestLoginOnExternal(request: Login.Data.Request) {
        worker.openLoginAuthorizeOnSafari()
    }
    
    func requestToken() {
        worker.requestTokenFromServer { success, error in
            self.isLoggedIn = success
            let response = Login.Data.Response(success: success, error: error)
            self.presenter?.presentHomeView(response: response)
        }
    }
    
    func checkIfLogged() {
        if let _ = K.Auth.accessToken, let _ = K.Auth.refreshToken {
            self.isLoggedIn = true
            let response = Login.Data.Response(success: true, error: nil)
            presenter?.presentHomeView(response: response)
        } else {
            worker.hasLoggedIn { success, error in
                self.isLoggedIn = success
                let response = Login.Data.Response(success: success, error: error)
                self.presenter?.presentHomeView(response: response)
            }
        }
    }
}
