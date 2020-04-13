//
//  LoginViewController.swift
//  MusicPod
//
//  Created by Anderson Soares Rodrigues on 26/03/20.
//  Copyright (c) 2020 Anderson Soares Rodrigues. All rights reserved.
//

import UIKit

protocol LoginDisplayLogic: class {
    func displayHome(viewModel: Login.Data.ViewModel)
}

class LoginViewController: UIViewController, LoginDisplayLogic {
    var interactor: LoginBusinessLogic?
    var router: (NSObjectProtocol & LoginRoutingLogic)?
    
    // MARK: Object lifecycle
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: Setup
    
    private func setup() {
        let viewController = self
        let interactor = LoginInteractor()
        let presenter = LoginPresenter()
        let router = LoginRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        
        interactor.checkIfLogged()
    }
    
    // MARK: Routing
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let scene = segue.identifier {
            let selector = NSSelectorFromString("routeTo\(scene)WithSegue:")
            if let router = router, router.responds(to: selector) {
                router.perform(selector, with: segue)
            }
        }
    }
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLoggginIn(false)
    }
    
    // MARK: Do something
    
    @IBOutlet weak var loginViaSpotifyButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBAction func requestLoginViaSpotify(_ sender: Any) {
        setLoggginIn(true)
        requestLoginOnExternal()
    }
    
    func requestLoginOnExternal() {
        let request = Login.Data.Request()
        interactor?.requestLoginOnExternal(request: request)
    }
    
    func requestTokenOnExternal() {
        interactor?.requestToken()
    }
    
    func displayHome(viewModel: Login.Data.ViewModel) {
        if viewModel.success {
            performSegue(withIdentifier: "segueHome", sender: self)
        }
        setLoggginIn(viewModel.success)
    }
    
    func setLoggginIn(_ logginIn: Bool) {
        if logginIn {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
        loginViaSpotifyButton.isEnabled = !logginIn
    }
}
