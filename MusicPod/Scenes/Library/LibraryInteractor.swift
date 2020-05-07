//
//  LibraryInteractor.swift
//  MusicPod
//
//  Created by Anderson Rodrigues on 13/04/2020.
//  Copyright (c) 2020 Anderson Soares Rodrigues. All rights reserved.
//

import UIKit

// MARK: - Protocol
protocol LibraryBusinessLogic {
    // MARK: Request Handle
    func requestPlaylistList(request: LibraryModel.PlaylistList.Request)
    func requestAlbumList(request: LibraryModel.AlbumList.Request)
    func requestCoverImage(request: LibraryModel.CoverImage.Request)
    
    // MARK: Refresh Request Handle
    func requestRefreshPlaylistList(request: LibraryModel.PlaylistList.Request)
    func requestRefreshAlbumList(request: LibraryModel.AlbumList.Request)
    
    // MARK: CRUD operations
    func fetchPlaylistAndConfigureCell(request: LibraryModel.FetchPlaylistAndConfigureCell.Request)
    func fetchAlbumAndConfigureCell(request: LibraryModel.FetchAlbumAndConfigureCell.Request)
    
    // MARK: Count
    func count(as type: LibrarySegmentKey) -> Int
    
    // MARK: Library update lifecycle
    func startLibraryUpdates(request: LibraryModel.StartLibraryUpdates.Request)
    func stopLibraryUpdates(request: LibraryModel.StopLibraryUpdates.Request)
    
    // MARK: Data Segue
    func provideDataToMusicView(at indexPath: IndexPath, as type: LibrarySegmentKey)
}

protocol LibraryDataStore {
    var album: Album? { get set }
    var playlist: Playlist? { get set }
}

class LibraryInteractor: LibraryBusinessLogic, LibraryDataStore {
    
    var album: Album?
    var playlist: Playlist?
    
    var presenter: LibraryPresentationLogic?
    var worker: LibraryWorker?
    var albumWorker = LibraryModel.albumWorker
    var playlistWorker = LibraryModel.playlistWorker
    
    // MARK: Request Handle
    func requestPlaylistList(request: LibraryModel.PlaylistList.Request) {
        worker = LibraryWorker()
        
        if let worker = worker {
            worker.fetchPlaylistList { (response) in
                self.presenter?.presentPlaylistList(response: response)
            }
        }
    }
    
    func requestAlbumList(request: LibraryModel.AlbumList.Request) {
        worker = LibraryWorker()
        
        if let worker = worker {
            worker.fetchAlbumList { (response) in
                self.presenter?.presentAlbumList(response: response)
            }
        }
    }
    
    func requestCoverImage(request: LibraryModel.CoverImage.Request) {
        worker = LibraryWorker()
        
        if let worker = worker {
            if request.type == .album {
                worker.fetchAlbumCoverImage(request: request) { (response) in
                    self.presenter?.presentCoverImage(response: response)
                }
            } else if request.type == .playlist {
                worker.fetchPlaylistCoverImage(request: request) { (response) in
                    self.presenter?.presentCoverImage(response: response)
                }
            }
        }
    }
    
    // MARK: Refresh Request Handle
    
    func requestRefreshAlbumList(request: LibraryModel.AlbumList.Request) {
        worker = LibraryWorker()
        
        if let worker = worker {
            worker.fetchRefreshAlbumList { (response) in
                self.presenter?.presentAlbumList(response: response)
            }
        }
    }
    
    func requestRefreshPlaylistList(request: LibraryModel.PlaylistList.Request) {
        worker = LibraryWorker()
        
        if let worker = worker {
            worker.fetchRefreshPlaylistList { (response) in
                self.presenter?.presentPlaylistList(response: response)
            }
        }
    }
    
    // MARK: CRUD operations
    
    func fetchAlbumAndConfigureCell(request: LibraryModel.FetchAlbumAndConfigureCell.Request) {
        let album = albumWorker.read(at: request.indexPath)
        
        let response = LibraryModel.FetchAlbumAndConfigureCell.Response(album: album, indexPath: request.indexPath, cell: request.cell)
        presenter?.presentFetchedAlbumListAndConfigureCell(response: response)
    }
    
    func fetchPlaylistAndConfigureCell(request: LibraryModel.FetchPlaylistAndConfigureCell.Request) {
        let playlist = playlistWorker.read(at: request.indexPath)
        
        let response = LibraryModel.FetchPlaylistAndConfigureCell.Response(playlist: playlist, indexPath: request.indexPath, cell: request.cell)
        presenter?.presentFetchedPlaylistListAndConfigureCell(response: response)
    }
    
    // MARK: Count
    
    func count(as type: LibrarySegmentKey) -> Int {
        if type == .album {
            return albumWorker.count()
        } else if type == .playlist {
            return playlistWorker.count()
        }
        
        return 0
    }
    
    // MARK: Data Segue
    func provideDataToMusicView(at indexPath: IndexPath, as type: LibrarySegmentKey) {
        if type == .album {
            album = albumWorker.read(at: indexPath)
        } else if type == .playlist {
            playlist = playlistWorker.read(at: indexPath)
        }
    }
}

// MARK: - NSFetchedResultsController

extension LibraryInteractor: AlbumCoreDataWorkerDelegate, PlaylistCoreDataWorkerDelegate {
    
    // MARK: Library update lifecycle
    
    func startLibraryUpdates(request: LibraryModel.StartLibraryUpdates.Request) {
        albumWorker.delegates.append(self)
        playlistWorker.delegates.append(self)
    }
    
    func stopLibraryUpdates(request: LibraryModel.StopLibraryUpdates.Request) {
        if let index = albumWorker.delegates.firstIndex(where: { $0 === self }) {
            albumWorker.delegates.remove(at: index)
        }
        
        if let index = playlistWorker.delegates.firstIndex(where: { $0 === self }) {
            playlistWorker.delegates.remove(at: index)
        }
    }
    
    // MARK: Album row updates
    
    func albumCoreDataWorkerWillUpdate(albumCoreDataWorker: AlbumCoreDataWorker) {
        let response = LibraryModel.StartLibraryUpdates.Response()
        presenter?.presentStartLibraryUpdates(response: response)
    }
    
    func albumCoreDataWorkerDidUpdate(albumCoreDataWorker: AlbumCoreDataWorker) {
        let response = LibraryModel.StopLibraryUpdates.Response()
        presenter?.presentStopLibraryUpdates(response: response)
    }
    
    func albumCoreDataWorker(albumCoreDataWorker: AlbumCoreDataWorker, shouldInsertRowAt indexPath: IndexPath) {
        presenter?.presentInsertedRow(at: indexPath)
    }
    
    func albumCoreDataWorker(albumCoreDataWorker: AlbumCoreDataWorker, shouldDeleteRowAt indexPath: IndexPath) {
        presenter?.presentDeletedRow(at: indexPath)
    }
    
    func albumCoreDataWorker(albumCoreDataWorker: AlbumCoreDataWorker, shouldUpdateRowAt indexPath: IndexPath, withAlbum album: Album) {
        presenter?.presentUpdatedRow(at: indexPath, withAlbum: album, withPlaylist: nil)
    }
    
    func albumCoreDataWorker(albumCoreDataWorker: AlbumCoreDataWorker, shouldMoveRowFrom from: IndexPath, to: IndexPath, withAlbum album: Album) {
        presenter?.presentMovedRow(from: from, to: to, withAlbum: album, withPlaylist: nil)
    }
    
    // MARK: Playlist row updates
    
    func playlistCoreDataWorkerWillUpdate(playlistCoreDataWorker: PlaylistCoreDataWorker) {
        let response = LibraryModel.StartLibraryUpdates.Response()
        presenter?.presentStartLibraryUpdates(response: response)
    }
    
    func playlistCoreDataWorkerDidUpdate(playlistCoreDataWorker: PlaylistCoreDataWorker) {
        let response = LibraryModel.StopLibraryUpdates.Response()
        presenter?.presentStopLibraryUpdates(response: response)
    }
    
    func playlistCoreDataWorker(playlistCoreDataWorker: PlaylistCoreDataWorker, shouldInsertRowAt indexPath: IndexPath) {
        presenter?.presentInsertedRow(at: indexPath)
    }
    
    func playlistCoreDataWorker(playlistCoreDataWorker: PlaylistCoreDataWorker, shouldDeleteRowAt indexPath: IndexPath) {
        presenter?.presentDeletedRow(at: indexPath)
    }
    
    func playlistCoreDataWorker(playlistCoreDataWorker: PlaylistCoreDataWorker, shouldUpdateRowAt indexPath: IndexPath, withPlaylist playlist: Playlist) {
        presenter?.presentUpdatedRow(at: indexPath, withAlbum: nil, withPlaylist: playlist)
    }
    
    func playlistCoreDataWorker(playlistCoreDataWorker: PlaylistCoreDataWorker, shouldMoveRowFrom from: IndexPath, to: IndexPath, withPlaylist playlist: Playlist) {
        presenter?.presentMovedRow(from: from, to: to, withAlbum: nil, withPlaylist: playlist)
    }
}
