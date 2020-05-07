//
//  UIViewController+Extension.swift
//  MusicPod
//
//  Created by Anderson Rodrigues on 03/04/2020.
//  Copyright © 2020 Anderson Rodrigues. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func showAlertFailure(title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
    
    private func initDarkModeView() {
        view.backgroundColor = #colorLiteral(red: 0.145080179, green: 0.1451074183, blue: 0.1450739205, alpha: 1)
        
        navigationController!.navigationBar.barStyle = .black
        navigationController!.navigationBar.isTranslucent = true
        navigationController!.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController!.navigationBar.tintColor = #colorLiteral(red: 1, green: 0.99997437, blue: 0.9999912977, alpha: 1)
    }
    
    func setDarkMode(tableView: UITableView?) {
        initDarkModeView()
        
        if let tableView = tableView {
            tableView.backgroundColor = #colorLiteral(red: 0.145080179, green: 0.1451074183, blue: 0.1450739205, alpha: 1)
        }
    }
    
    func setDarkMode(collectionView: UICollectionView?) {
        initDarkModeView()

        if let collectionView = collectionView {
            collectionView.backgroundColor = #colorLiteral(red: 0.145080179, green: 0.1451074183, blue: 0.1450739205, alpha: 1)
        }
    }
}
