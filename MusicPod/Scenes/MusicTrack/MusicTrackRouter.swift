//
//  MusicTrackRouter.swift
//  MusicPod
//
//  Created by Anderson Rodrigues on 15/04/2020.
//  Copyright (c) 2020 Anderson Soares Rodrigues. All rights reserved.
//

import UIKit

@objc protocol MusicTrackRoutingLogic {
	//func routeToSomewhere(segue: UIStoryboardSegue?)
}

protocol MusicTrackDataPassing {
	var dataStore: MusicTrackDataStore? { get }
}

class MusicTrackRouter: NSObject, MusicTrackRoutingLogic, MusicTrackDataPassing {
	weak var viewController: MusicTrackViewController?
	var dataStore: MusicTrackDataStore?
	
	// MARK: Routing
	
	//func routeToSomewhere(segue: UIStoryboardSegue?) {
	//  if let segue = segue {
	//    let destinationVC = segue.destination as! SomewhereViewController
	//    var destinationDS = destinationVC.router!.dataStore!
	//    passDataToSomewhere(source: dataStore!, destination: &destinationDS)
	//  } else {
	//    let storyboard = UIStoryboard(name: "Main", bundle: nil)
	//    let destinationVC = storyboard.instantiateViewController(withIdentifier: "SomewhereViewController") as! SomewhereViewController
	//    var destinationDS = destinationVC.router!.dataStore!
	//    passDataToSomewhere(source: dataStore!, destination: &destinationDS)
	//    navigateToSomewhere(source: viewController!, destination: destinationVC)
	//  }
	//}

	// MARK: Navigation
	
	//func navigateToSomewhere(source: MusicTrackViewController, destination: SomewhereViewController) {
	//  source.show(destination, sender: nil)
	//}
	
	// MARK: Passing data
	
	//func passDataToSomewhere(source: MusicTrackDataStore, destination: inout SomewhereDataStore) {
	//  destination.name = source.name
	//}
}
