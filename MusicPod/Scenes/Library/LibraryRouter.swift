//
//  LibraryRouter.swift
//  MusicPod
//
//  Created by Anderson Rodrigues on 13/04/2020.
//  Copyright (c) 2020 Anderson Soares Rodrigues. All rights reserved.
//

import UIKit

@objc protocol LibraryRoutingLogic {
    func routeToMusicView(segue: UIStoryboardSegue?)
}

protocol LibraryDataPassing {
    var dataStore: LibraryDataStore? { get }
}

class LibraryRouter: NSObject, LibraryRoutingLogic, LibraryDataPassing {
    weak var viewController: LibraryViewController?
    var dataStore: LibraryDataStore?
    
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
    
    func navigateToMusicView(source: LibraryViewController, destination: MusicTrackViewController) {
        source.show(destination, sender: nil)
    }
    
    // MARK: Passing data
    
    func passDataToMusicView(source: LibraryDataStore, destination: inout MusicTrackDataStore) {
        destination.album = source.album
        destination.playlist = source.playlist
    }
}
