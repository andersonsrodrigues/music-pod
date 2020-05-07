//
//  CategoryPlaylistModels.swift
//  MusicPod
//
//  Created by Anderson Rodrigues on 13/04/2020.
//  Copyright (c) 2020 Anderson Soares Rodrigues. All rights reserved.
//

import UIKit

enum CategoryPlaylistModel {
    
    // MARK: - External Workers
    
    static var playlistWorker = PlaylistCoreDataWorker.shared
    
    // MARK: - Model
    struct DisplayedCell {
        var image: Data?
        var url: String?
    }
    
    struct DisplayedEntry {
        var cover: UIImage
    }
    
    // MARK: - CRUD operations
    
    enum List {
        struct Request { }
        struct Response {
            var playlists: [Playlist]
            var isError: Bool
            var message: String?
        }
        struct ViewModel {
            var playlists: [Playlist]
            var isError: Bool
            var message: String?
        }
    }
    
    enum FetchListAndConfigureCell {
        struct Request {
            var indexPath: IndexPath
            var cell: PlaylistCollectionViewCell?
        }
        struct Response {
            var playlist: Playlist
            var indexPath: IndexPath
            var cell: PlaylistCollectionViewCell?
        }
        struct ViewModel {
            var displayedPlaylist: DisplayedCell
            var indexPath: IndexPath
            var cell: PlaylistCollectionViewCell?
        }
    }
    
    enum CoverImage {
        struct Request {
            var url: String
            var indexPath: IndexPath
            var cell: PlaylistCollectionViewCell
        }
        struct Response {
            var entry: Entry
            var cell: PlaylistCollectionViewCell
        }
        struct ViewModel {
            var displayedEntry: DisplayedEntry
            var cell: PlaylistCollectionViewCell
        }
    }
    
    // MARK: - Category Playlist update lifecycle
    
    enum StartCategoryPlaylistUpdates {
        struct Request { }
        struct Response { }
        struct ViewModel { }
    }
    
    enum StopCategoryPlaylistUpdates {
        struct Request { }
        struct Response { }
        struct ViewModel { }
    }
}
