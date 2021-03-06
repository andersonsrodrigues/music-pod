//
//  LoginPresenter.swift
//  MusicPod
//
//  Created by Anderson Soares Rodrigues on 26/03/20.
//  Copyright (c) 2020 Anderson Soares Rodrigues. All rights reserved.
//

import UIKit

protocol LoginPresentationLogic {
    func presentHomeView(response: LoginModel.Data.Response)
}

class LoginPresenter: LoginPresentationLogic {
    weak var viewController: LoginDisplayLogic?
    
    // MARK: Do something
    
    func presentHomeView(response: LoginModel.Data.Response) {
        let viewModel = LoginModel.Data.ViewModel(success: response.success, error: response.error)
        viewController?.displayHome(viewModel: viewModel)
    }
}
