//
//  HomeRouter.swift
//  MusicPod
//
//  Created by Anderson Soares Rodrigues on 26/03/20.
//  Copyright (c) 2020 Anderson Soares Rodrigues. All rights reserved.
//

import UIKit

@objc protocol HomeRoutingLogic {
    func routeToMusicView(segue: UIStoryboardSegue?)
}

protocol HomeDataPassing {
    var dataStore: HomeDataStore? { get }
}

class HomeRouter: NSObject, HomeRoutingLogic, HomeDataPassing {
    weak var viewController: HomeViewController?
    var dataStore: HomeDataStore?
    
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
            navigateToMusicView(source: viewController!, destination: destinationVC)
        }
    }
    
    // MARK: Navigation
    
    func navigateToMusicView(source: HomeViewController, destination: MusicTrackViewController) {
        source.show(destination, sender: nil)
    }
    
    // MARK: Passing data
    
    func passDataToMusicView(source: HomeDataStore, destination: inout MusicTrackDataStore) {
        destination.playlist = source.playlist
        destination.album = source.album
        destination.artist = source.artist
    }
}
