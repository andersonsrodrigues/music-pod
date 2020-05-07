//
//  CategoryPlaylistInteractor.swift
//  MusicPod
//
//  Created by Anderson Rodrigues on 13/04/2020.
//  Copyright (c) 2020 Anderson Soares Rodrigues. All rights reserved.
//

import UIKit

// MARK: - Protocol
protocol CategoryPlaylistBusinessLogic {
    // MARK: Request Handle
    func requestCategoryPlaylistList(request: CategoryPlaylistModel.List.Request)
    func requestRefreshCategoryPlaylistList(request: CategoryPlaylistModel.List.Request)
    func requestCoverImage(request: CategoryPlaylistModel.CoverImage.Request)
    
    // MARK: CRUD operations
    func fetchCategoryPlaylistList(request: CategoryPlaylistModel.FetchListAndConfigureCell.Request)
    
    // MARK: Count
    func count() -> Int
    
    // MARK: Category Playlist update lifecycle
    func startCategoryPlaylistUpdates(request: CategoryPlaylistModel.StartCategoryPlaylistUpdates.Request)
    func stopCategoryPlaylistUpdates(request: CategoryPlaylistModel.StopCategoryPlaylistUpdates.Request)
    
    // MARK: Category Name
    func getCategoryName() -> String
    
    // MARK: Prepare for segue
    func provideDataToMusicViewSegue(at indexPath: IndexPath)
}

protocol CategoryPlaylistDataStore {
    var categoryID: String? { get set }
    var categoryName: String? { get set }
    var category: Category? { get set }
    var playlist: Playlist { get set }
}

class CategoryPlaylistInteractor: CategoryPlaylistBusinessLogic, CategoryPlaylistDataStore {
    var categoryID: String?
    var categoryName: String?
    var category: Category?
    var playlist: Playlist = Playlist()
    
    var presenter: CategoryPlaylistPresentationLogic?
    var worker: CategoryPlaylistWorker?
    var playlistWorker = CategoryPlaylistModel.playlistWorker
    
    // MARK: Request Handle
    
    func requestCategoryPlaylistList(request: CategoryPlaylistModel.List.Request) {
        worker = CategoryPlaylistWorker()
        
        if let worker = worker {
            worker.fetchCategoryPlaylistList(category!) { (response) in
                self.presenter?.presentCategoryPlaylistList(response: response)
            }
        }
    }
    
    func requestRefreshCategoryPlaylistList(request: CategoryPlaylistModel.List.Request) {
        worker = CategoryPlaylistWorker()
        
        if let worker = worker {
            worker.fetchRefreshCategoryPlaylistList(category!) { (response) in
                self.presenter?.presentCategoryPlaylistList(response: response)
            }
        }
    }
    
    func requestCoverImage(request: CategoryPlaylistModel.CoverImage.Request) {
        worker = CategoryPlaylistWorker()
        
        if let worker = worker {
            worker.fetchCategoryPlaylistCoverImage(request: request) { (response) in
                self.presenter?.presentCoverImage(response: response)
            }
        }
    }
    
    // MARK: Count
    
    func count() -> Int {
        return playlistWorker.count()
    }
    
    // MARK: Fetch Results
    
    func fetchCategoryPlaylistList(request: CategoryPlaylistModel.FetchListAndConfigureCell.Request) {
        let playlist = playlistWorker.read(at: request.indexPath)
        
        let response = CategoryPlaylistModel.FetchListAndConfigureCell.Response(playlist: playlist, indexPath: request.indexPath, cell: request.cell)
        presenter?.presentFetchedCategoryPlaylistListAndConfigureCell(response: response)
    }
    
    // MARK: Category Name
    func getCategoryName() -> String {
        return categoryName ?? "Unknown"
    }
    
    // MARK: Segue
    func provideDataToMusicViewSegue(at indexPath: IndexPath) {
        let playlistData = playlistWorker.read(at: indexPath)
        
        playlist = playlistData
    }
}

// MARK: - NSFetchedResultsController
extension CategoryPlaylistInteractor: PlaylistCoreDataWorkerDelegate {
    // MARK: Category Playlist update lifecycle
    
    func startCategoryPlaylistUpdates(request: CategoryPlaylistModel.StartCategoryPlaylistUpdates.Request) {
        playlistWorker.delegates.append(self)
    }
    
    func stopCategoryPlaylistUpdates(request: CategoryPlaylistModel.StopCategoryPlaylistUpdates.Request) {
        if let index = playlistWorker.delegates.firstIndex(where: { $0 === self }) {
            playlistWorker.delegates.remove(at: index)
        }
    }
    
    // MARK: Category Playlist row updates
    
    func playlistCoreDataWorker(playlistCoreDataWorker: PlaylistCoreDataWorker, shouldInsertRowAt indexPath: IndexPath) {
        presenter?.presentInsertRow(at: indexPath)
    }
    
    func playlistCoreDataWorker(playlistCoreDataWorker: PlaylistCoreDataWorker, shouldDeleteRowAt indexPath: IndexPath) {
        presenter?.presentDeleteRow(at: indexPath)
    }
    
    func playlistCoreDataWorker(playlistCoreDataWorker: PlaylistCoreDataWorker, shouldUpdateRowAt indexPath: IndexPath, withPlaylist playlist: Playlist) {
        presenter?.presentUpdatedRow(at: indexPath, withPlaylist: playlist)
    }
    
    func playlistCoreDataWorker(playlistCoreDataWorker: PlaylistCoreDataWorker, shouldMoveRowFrom from: IndexPath, to: IndexPath, withPlaylist playlist: Playlist) {
        presenter?.presentMoveRow(from: from, to: to, withPlaylist: playlist)
    }
}
