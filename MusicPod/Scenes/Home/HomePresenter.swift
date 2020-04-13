//
//  HomePresenter.swift
//  MusicPod
//
//  Created by Anderson Soares Rodrigues on 26/03/20.
//  Copyright (c) 2020 Anderson Soares Rodrigues. All rights reserved.
//

import UIKit

protocol HomePresentationLogic {
    func presentTopArtists(response: Home.TopArtists.Response)
    func presentNewRelease(response: Home.NewRelease.Response)
    func presentFeaturedPlaylist(response: Home.FeaturePlaylists.Response)
}

class HomePresenter: HomePresentationLogic {
    weak var viewController: HomeDisplayLogic?
    
    // MARK: Do something
    
    func presentTopArtists(response: Home.TopArtists.Response) {
        let viewModel = Home.TopArtists.ViewModel(artists: response.artists)
        viewController?.displayTopArtists(viewModel: viewModel)
    }
    
    func presentNewRelease(response: Home.NewRelease.Response) {
        let viewModel = Home.NewRelease.ViewModel(releases: response.releases)
        viewController?.displayNewRelease(viewModel: viewModel)
    }
    
    func presentFeaturedPlaylist(response: Home.FeaturePlaylists.Response) {
        let viewModel = Home.FeaturePlaylists.ViewModel(playlists: response.playlists)
        viewController?.displayFeaturedPlaylist(viewModel: viewModel)
    }
}
