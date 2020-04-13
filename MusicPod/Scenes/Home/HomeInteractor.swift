//
//  HomeInteractor.swift
//  MusicPod
//
//  Created by Anderson Soares Rodrigues on 26/03/20.
//  Copyright (c) 2020 Anderson Soares Rodrigues. All rights reserved.
//

import UIKit

protocol HomeBusinessLogic {
    func requestLastPlaylists()
    func requestNewRelease()
    func requestFeaturePlaylists()
    func setCover(request: Home.SetCover.Request)
}

protocol HomeDataStore {
    //var name: String { get set }
}

class HomeInteractor: HomeBusinessLogic, HomeDataStore {
    var presenter: HomePresentationLogic?
    var worker: HomeWorker?
    
    private var entries = [Entry]()
    
    // MARK: Do something
    
    func requestLastPlaylists() {
        worker = HomeWorker()
        
        if let worker = worker {
            worker.getUserTopArtistsAndTracks(as: "artists") { (data, error) in
                let response = Home.TopArtists.Response(artists: data)
                self.presenter?.presentTopArtists(response: response)
            }
        }
    }
    
    func requestNewRelease() {
        worker = HomeWorker()
        
        if let worker = worker {
            worker.getListNewReleases { (data, error) in
                let response = Home.NewRelease.Response(releases: data)
                self.presenter?.presentNewRelease(response: response)
            }
        }
    }
    
    func requestFeaturePlaylists() {
        worker = HomeWorker()
        
        if let worker = worker {
            worker.getListFeaturedPlaylist { (data, error) in
                let response = Home.FeaturePlaylists.Response(playlists: data)
                self.presenter?.presentFeaturedPlaylist(response: response)
            }
        }
    }
    
    // MARK: Set icon
    
    func setCover(request: Home.SetCover.Request) {
        worker?.downloadPosterImage(path: request.url, completion: { (data, error) in
            if let data = data {
//                let response = Home.SetCover.Response(entry: entry, indexPath: request.indexPath)
//                presenter?.presentSetIcon(response: response)
            }
        })
    }
}
