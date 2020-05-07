//
//  SearchRouter.swift
//  MusicPod
//
//  Created by Anderson Rodrigues on 15/04/2020.
//  Copyright (c) 2020 Anderson Soares Rodrigues. All rights reserved.
//

import UIKit

@objc protocol SearchRoutingLogic {
	func routeToMusicView(segue: UIStoryboardSegue?)
}

protocol SearchDataPassing {
	var dataStore: SearchDataStore? { get }
}

class SearchRouter: NSObject, SearchRoutingLogic, SearchDataPassing {
	weak var viewController: SearchViewController?
	var dataStore: SearchDataStore?
	
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
	
	func navigateToMusicView(source: SearchViewController, destination: MusicTrackViewController) {
        source.show(destination, sender: nil)
	}
	
	// MARK: Passing data
	
	func passDataToMusicView(source: SearchDataStore, destination: inout MusicTrackDataStore) {
        destination.searchResult = source.search
	}
}
