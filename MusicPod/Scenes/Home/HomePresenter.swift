//
//  HomePresenter.swift
//  MusicPod
//
//  Created by Anderson Soares Rodrigues on 26/03/20.
//  Copyright (c) 2020 Anderson Soares Rodrigues. All rights reserved.
//

import UIKit

// MARK: - Protocol
protocol HomePresentationLogic {
    // MARK: Fetch Handle
    func presentTopArtists(response: HomeModel.TopArtists.Response)
    func presentNewRelease(response: HomeModel.NewRelease.Response)
    func presentFeaturedPlaylist(response: HomeModel.FeaturePlaylists.Response)
    func presentCoverImage(response: HomeModel.CoverImage.Response)
    
    // MARK: CRUD operations
    func presentFetchedTopArtistAndConfigureCell(response: HomeModel.FetchTopArtistAndConfigureCell.Response)
    func presentFetchedNewReleaseAndConfigureCell(response: HomeModel.FetchNewReleaseAndConfigureCell.Response)
    func presentFetchedFeaturePlaylistsAndConfigureCell(response: HomeModel.FetchFeaturePlaylistsAndConfigureCell.Response)
    
    // MARK: Home update lifecycle
    func presentStartHomeUpdates(response: HomeModel.StartHomeUpdates.Response)
    func presentStopHomeUpdates(response: HomeModel.StopHomeUpdates.Response)
}

class HomePresenter: HomePresentationLogic {
    
    weak var viewController: HomeDisplayLogic?
    
    // MARK: Fetch Handle
    
    func presentTopArtists(response: HomeModel.TopArtists.Response) {
        let viewModel = HomeModel.TopArtists.ViewModel(artists: response.artists, isError: response.isError, message: response.message)
        
        if response.isError {
            viewController?.displayErrorFetchTopArtists(viewModel: viewModel)
        } else {
            viewController?.displayTopArtists(viewModel: viewModel)
        }
    }
    
    func presentNewRelease(response: HomeModel.NewRelease.Response) {
        let viewModel = HomeModel.NewRelease.ViewModel(albums: response.albums, isError: response.isError, message: response.message)
        
        if response.isError {
            viewController?.displayErrorFetchNewRelease(viewModel: viewModel)
        } else {
            viewController?.displayNewRelease(viewModel: viewModel)
        }
    }
    
    func presentFeaturedPlaylist(response: HomeModel.FeaturePlaylists.Response) {
        let viewModel = HomeModel.FeaturePlaylists.ViewModel(playlists: response.playlists, isError: response.isError, message: response.message)
        
        if response.isError {
            viewController?.displayErrorFetchFeaturedPlaylist(viewModel: viewModel)
        } else {
            viewController?.displayFeaturedPlaylist(viewModel: viewModel)
        }
    }
    
    func presentCoverImage(response: HomeModel.CoverImage.Response) {
        let displayEntry = convert(entry: response.entry)
        let viewModel = HomeModel.CoverImage.ViewModel(displayedEntry: displayEntry, cell: response.cell)
        viewController?.displayCoverImage(viewModel: viewModel)
    }
    
    // MARK: CRUD operations
    
    func presentFetchedTopArtistAndConfigureCell(response: HomeModel.FetchTopArtistAndConfigureCell.Response) {
        let displayedTopArtist = formatCell(artist: response.artist, album: nil, playlist: nil)
        
        let viewModel = HomeModel.FetchTopArtistAndConfigureCell.ViewModel(displayedArtist: displayedTopArtist!, cell: response.cell, indexPath: response.indexPath)
        viewController?.displayFetchedArtistsAndConfigureCell(viewModel: viewModel)
    }
    
    func presentFetchedNewReleaseAndConfigureCell(response: HomeModel.FetchNewReleaseAndConfigureCell.Response) {
        let displayedNewRelease = formatCell(artist: nil, album: response.album, playlist: nil)
        
        let viewModel = HomeModel.FetchNewReleaseAndConfigureCell.ViewModel(displayedAlbum: displayedNewRelease!, cell: response.cell, indexPath: response.indexPath)
        viewController?.displayFetchedAlbumsAndConfigureCell(viewModel: viewModel)
    }
    
    func presentFetchedFeaturePlaylistsAndConfigureCell(response: HomeModel.FetchFeaturePlaylistsAndConfigureCell.Response) {
        let displayedFeaturePlaylists = formatCell(artist: nil, album: nil, playlist: response.playlist)
        
        let viewModel = HomeModel.FetchFeaturePlaylistsAndConfigureCell.ViewModel(displayedPlaylist: displayedFeaturePlaylists!, cell: response.cell, indexPath: response.indexPath)
        viewController?.displayFetchedPlaylistsAndConfigureCell(viewModel: viewModel)
    }
    
    // MARK: Format entry to displayed entry
    
    private func convert(entry: Entry) -> HomeModel.DisplayedEntry {
        let image = UIImage(data: entry.cover)
        return HomeModel.DisplayedEntry(cover: image!)
    }
    
    // MARK: - Format Artist & Album & Playlist
    
    func formatCell(artist: Artist?, album: Album?, playlist: Playlist?) -> HomeModel.DisplayedCell? {
        if let data = artist {
            return HomeModel.DisplayedCell(name: data.name!, image: data.image, url: data.imageUrl)
        } else if let data = album {
            return HomeModel.DisplayedCell(name: data.name!, image: data.image, url: data.imageUrl)
        } else if let data = playlist {
            return HomeModel.DisplayedCell(name: data.name!, image: data.image, url: data.imageUrl)
        }
        
        return nil
    }
}

// MARK: - NSFetchedResultsController

extension HomePresenter {
    
    // MARK: Home update lifecycle
    
    func presentStartHomeUpdates(response: HomeModel.StartHomeUpdates.Response) {
        let viewModel = HomeModel.StartHomeUpdates.ViewModel()
        viewController?.displayStartHomeUpdates(viewModel: viewModel)
    }
    
    func presentStopHomeUpdates(response: HomeModel.StopHomeUpdates.Response) {
        let viewModel = HomeModel.StopHomeUpdates.ViewModel()
        viewController?.displayStopHomeUpdates(viewModel: viewModel)
    }
}
