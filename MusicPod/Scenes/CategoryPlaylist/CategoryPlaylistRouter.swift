//
//  CategoryPlaylistRouter.swift
//  MusicPod
//
//  Created by Anderson Rodrigues on 13/04/2020.
//  Copyright (c) 2020 Anderson Soares Rodrigues. All rights reserved.
//

import UIKit

@objc protocol CategoryPlaylistRoutingLogic {
    func routeToMusicView(segue: UIStoryboardSegue?)
}

protocol CategoryPlaylistDataPassing {
    var dataStore: CategoryPlaylistDataStore? { get }
}

class CategoryPlaylistRouter: NSObject, CategoryPlaylistRoutingLogic, CategoryPlaylistDataPassing {
    weak var viewController: CategoryPlaylistViewController?
    var dataStore: CategoryPlaylistDataStore?
    
    // MARK: Routing
    
    func routeToMusicView(segue: UIStoryboardSegue?) {
        if let segue = segue {
            let destinationVC = segue.destination as! MusicTrackViewController
            var destinationDS = destinationVC.router!.dataStore!
            passDataToMusicView(source: dataStore!, destination: &destinationDS)
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let destinationVC = storyboard.instantiateViewController(withIdentifier: "MusicTrackViewController") as! MusicTrackViewController
            var destinationDS = destinationVC.router!.dataStore!
            passDataToMusicView(source: dataStore!, destination: &destinationDS)
            navigateToMusiView(source: viewController!, destination: destinationVC)
        }
    }
    
    // MARK: Navigation
    
    func navigateToMusiView(source: CategoryPlaylistViewController, destination: MusicTrackViewController) {
        source.show(destination, sender: nil)
    }
    
    // MARK: Passing data
    
    func passDataToMusicView(source: CategoryPlaylistDataStore, destination: inout MusicTrackDataStore) {
        destination.playlist = source.playlist
    }
}
