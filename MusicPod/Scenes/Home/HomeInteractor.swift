//
//  HomeInteractor.swift
//  MusicPod
//
//  Created by Anderson Soares Rodrigues on 26/03/20.
//  Copyright (c) 2020 Anderson Soares Rodrigues. All rights reserved.
//

import UIKit

// MARK: - Protocol
protocol HomeBusinessLogic {
    // MARK: Request Handle
    func requestTopArtistisAndTracks()
    func requestNewRelease()
    func requestFeaturePlaylists()
    func requestCoverImage(request: HomeModel.CoverImage.Request)
    
    // MARK: CRUD operations
    func fetchTopArtistAndConfigureCell(request: HomeModel.FetchTopArtistAndConfigureCell.Request)
    func fetchNewReleaseAndConfigureCell(request: HomeModel.FetchNewReleaseAndConfigureCell.Request)
    func fetchFeaturePlaylistAndConfigureCell(request: HomeModel.FetchFeaturePlaylistsAndConfigureCell.Request)
    
    // MARK: Count
    func count(as type: HomeSectionKeys) -> Int

    // MARK: Home update lifecycle
    func startHomeUpdates(request: HomeModel.StartHomeUpdates.Request)
    func stopHomeUpdates(request: HomeModel.StopHomeUpdates.Request)
    
    // MARK: Provide Data Store
    func provideDataToMusicView(at indexPath: IndexPath, as type: HomeSectionKeys)
}

protocol HomeDataStore {
    var playlist: Playlist? { get set }
    var album: Album? { get set }
    var artist: Artist? { get set }
}

class HomeInteractor: HomeBusinessLogic, HomeDataStore {
    
    weak var playlist: Playlist?
    weak var album: Album?
    weak var artist: Artist?
    
    var presenter: HomePresentationLogic?
    var worker: HomeWorker?
    var artistWorker = HomeModel.artistWorker
    var albumWorker = HomeModel.albumWorker
    var playlistWorker = HomeModel.playlistWorker
    
    private var entries = [Entry]()
    
    // MARK: - CRUD operations
    
    // MARK: Fetch events
    
    func requestTopArtistisAndTracks() {
        worker = HomeWorker()
        
        if let worker = worker {
            worker.fetchTopArtistsAndTracks { (response) in
                self.presenter?.presentTopArtists(response: response)
            }
        }
    }
    
    func requestNewRelease() {
        worker = HomeWorker()
        
        if let worker = worker {
            worker.fetchNewRelease { (response) in
                self.presenter?.presentNewRelease(response: response)
            }
        }
    }
    
    func requestFeaturePlaylists() {
        worker = HomeWorker()
        
        if let worker = worker {
            worker.fetchFeaturePlaylists { (response) in
                self.presenter?.presentFeaturedPlaylist(response: response)
            }
        }
    }
    
    // MARK: Cover Image
    
    func requestCoverImage(request: HomeModel.CoverImage.Request) {
        worker = HomeWorker()
        
        if let worker = worker {
            if request.type == .recommendation {
                worker.fetchArtistCoverImage(request: request) { (response) in
                    self.presenter?.presentCoverImage(response: response)
                }
            } else if request.type == .new {
                worker.fetchAlbumCoverImage(request: request) { (response) in
                    self.presenter?.presentCoverImage(response: response)
                }
            } else if request.type == .featured {
                worker.fetchPlaylistCoverImage(request: request) { (response) in
                    self.presenter?.presentCoverImage(response: response)
                }
            }
        }
    }
    
    // MARK: Count
    
    func count(as type: HomeSectionKeys) -> Int {
        switch type {
        case .recommendation:
            return artistWorker.count()
        case .new:
            return albumWorker.count()
        case .featured:
            return playlistWorker.count()
        }
    }
    
    // MARK: Fetch Results
    
    func fetchTopArtistAndConfigureCell(request: HomeModel.FetchTopArtistAndConfigureCell.Request) {
        let artist = artistWorker.read(at: request.indexPath)
      
        let response = HomeModel.FetchTopArtistAndConfigureCell.Response(artist: artist, cell: request.cell, indexPath: request.indexPath)
        presenter?.presentFetchedTopArtistAndConfigureCell(response: response)
    }
    
    func fetchNewReleaseAndConfigureCell(request: HomeModel.FetchNewReleaseAndConfigureCell.Request) {
        let album = albumWorker.read(at: request.indexPath)
      
        let response = HomeModel.FetchNewReleaseAndConfigureCell.Response(album: album, cell: request.cell, indexPath: request.indexPath)
        presenter?.presentFetchedNewReleaseAndConfigureCell(response: response)
    }
    
    func fetchFeaturePlaylistAndConfigureCell(request: HomeModel.FetchFeaturePlaylistsAndConfigureCell.Request) {
        let playlist = playlistWorker.read(at: request.indexPath)
      
        let response = HomeModel.FetchFeaturePlaylistsAndConfigureCell.Response(playlist: playlist, cell: request.cell, indexPath: request.indexPath)
        presenter?.presentFetchedFeaturePlaylistsAndConfigureCell(response: response)
    }
    
    // MARK: Data Segue
    func provideDataToMusicView(at indexPath: IndexPath, as type: HomeSectionKeys) {
        resetDataStore()
        
        switch type {
        case .recommendation:
            artist = artistWorker.read(at: indexPath)
        case .new:
            album = albumWorker.read(at: indexPath)
        case .featured:
            playlist = playlistWorker.read(at: indexPath)
        }
    }
    
    // MARK: Reset
    private func resetDataStore() {
        artist = nil
        album = nil
        playlist = nil
    }
}

// MARK: - NSFetchedResulstController
extension HomeInteractor: PlaylistCoreDataWorkerDelegate, AlbumCoreDataWorkerDelegate, ArtistCoreDataWorkerDelegate {
    
    // MARK: Home update lifecycle
    
    func startHomeUpdates(request: HomeModel.StartHomeUpdates.Request) {
        albumWorker.delegates.append(self)
        artistWorker.delegates.append(self)
        playlistWorker.delegates.append(self)
    }
    
    func stopHomeUpdates(request: HomeModel.StopHomeUpdates.Request) {
        if let index = albumWorker.delegates.firstIndex(where: { $0 === self }) {
            albumWorker.delegates.remove(at: index)
        }
        
        if let index = artistWorker.delegates.firstIndex(where: { $0 === self }) {
            artistWorker.delegates.remove(at: index)
        }
        
        if let index = playlistWorker.delegates.firstIndex(where: { $0 === self }) {
            playlistWorker.delegates.remove(at: index)
        }
    }
    
    // MARK: Album row updates
    
    func albumCoreDataWorkerWillUpdate(albumCoreDataWorker: AlbumCoreDataWorker) {
        let response = HomeModel.StartHomeUpdates.Response()
        presenter?.presentStartHomeUpdates(response: response)
    }
    
    func albumCoreDataWorkerDidUpdate(albumCoreDataWorker: AlbumCoreDataWorker) {
        let response = HomeModel.StopHomeUpdates.Response()
        presenter?.presentStopHomeUpdates(response: response)
    }
    
    // MARK: Artist row updates
    
    func artistCoreDataWorkerWillUpdate(artistCoreDataWorker: ArtistCoreDataWorker) {
        let response = HomeModel.StartHomeUpdates.Response()
        presenter?.presentStartHomeUpdates(response: response)
    }
    
    func artistCoreDataWorkerDidUpdate(artistCoreDataWorker: ArtistCoreDataWorker) {
        let response = HomeModel.StopHomeUpdates.Response()
        presenter?.presentStopHomeUpdates(response: response)
    }
    
    // MARK: Playlist row updates
    
    func playlistCoreDataWorkerWillUpdate(playlistCoreDataWorker: PlaylistCoreDataWorker) {
        let response = HomeModel.StartHomeUpdates.Response()
        presenter?.presentStartHomeUpdates(response: response)
    }
    
    func playlistCoreDataWorkerDidUpdate(playlistCoreDataWorker: PlaylistCoreDataWorker) {
        let response = HomeModel.StopHomeUpdates.Response()
        presenter?.presentStopHomeUpdates(response: response)
    }
}
