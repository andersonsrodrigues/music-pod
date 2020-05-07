//
//  SearchInteractor.swift
//  MusicPod
//
//  Created by Anderson Rodrigues on 15/04/2020.
//  Copyright (c) 2020 Anderson Soares Rodrigues. All rights reserved.
//

import UIKit

// MARK: - Protocol
protocol SearchBusinessLogic {
    // MARK: Request Handle
    func requestSearch(request: SearchModel.List.Request)
    func requestCoverImage(request: SearchModel.CoverImage.Request)
    
    // MARK: Provide Data
    func provideDataToMusicView(with result: SearchModel.DisplayedCell)
}

protocol SearchDataStore {
	var search: Search? { get set }
}

class SearchInteractor: SearchBusinessLogic, SearchDataStore {
    
    var search: Search?
    
	var presenter: SearchPresentationLogic?
	var worker: SearchWorker?
    var currentSearchTask: URLSessionTask?
	
	// MARK: Request Handle
    
    func requestSearch(request: SearchModel.List.Request) {
        worker = SearchWorker()
        
        if let worker = worker {
            currentSearchTask?.cancel()
            currentSearchTask = worker.fetchSearchList(request.query) { (response) in
                self.presenter?.presentSearchList(response: response)
            }
        }
    }
    
    // MARK: Cover Image
    
    func requestCoverImage(request: SearchModel.CoverImage.Request) {
        worker = SearchWorker()
        
        if let worker = worker {
            worker.fetchCoverImage(request: request) { (response) in
                self.presenter?.presentCoverImage(response: response)
            }
        }
    }
    
    // MARK: Data Segue
    
    func provideDataToMusicView(with result: SearchModel.DisplayedCell) {
        let item = Search(id: result.id, name: result.name, type: result.type, images: nil)
        search = item
    }
}
