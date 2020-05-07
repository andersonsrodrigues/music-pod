//
//  CategoryRouter.swift
//  MusicPod
//
//  Created by Anderson Rodrigues on 13/04/2020.
//  Copyright (c) 2020 Anderson Soares Rodrigues. All rights reserved.
//

import UIKit

@objc protocol CategoryRoutingLogic {
    func routeToCategoryPlaylist(segue: UIStoryboardSegue?)
}

protocol CategoryDataPassing {
    var dataStore: CategoryDataStore? { get }
}

class CategoryRouter: NSObject, CategoryRoutingLogic, CategoryDataPassing {
    weak var viewController: CategoryViewController?
    var dataStore: CategoryDataStore?
    
    // MARK: Routing
    
    func routeToCategoryPlaylist(segue: UIStoryboardSegue?) {
        if let segue = segue {
            let destinationVC = segue.destination as! CategoryPlaylistViewController
            var destinationDS = destinationVC.router!.dataStore!
            passDataToCategoryPlaylist(source: dataStore!, destination: &destinationDS)
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let destinationVC = storyboard.instantiateViewController(withIdentifier: "CategoryPlaylistViewController") as! CategoryPlaylistViewController
            var destinationDS = destinationVC.router!.dataStore!
            passDataToCategoryPlaylist(source: dataStore!, destination: &destinationDS)
            navigateToCategoryPlaylist(source: viewController!, destination: destinationVC)
        }
    }
    
    // MARK: Navigation
    
    func navigateToCategoryPlaylist(source: CategoryViewController, destination: CategoryPlaylistViewController) {
        source.show(destination, sender: nil)
    }
    
    // MARK: Passing data
    
    func passDataToCategoryPlaylist(source: CategoryDataStore, destination: inout CategoryPlaylistDataStore) {
        destination.categoryID = source.id!
        destination.categoryName = source.name!
        destination.category = source.category
    }
}
