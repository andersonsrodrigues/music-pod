//
//  LibraryModels.swift
//  MusicPod
//
//  Created by Anderson Rodrigues on 13/04/2020.
//  Copyright (c) 2020 Anderson Soares Rodrigues. All rights reserved.
//

import UIKit

enum LibraryModel {
    
    // MARK: - External Workers
    
    static var playlistWorker = PlaylistCoreDataWorker.shared
    static var albumWorker = AlbumCoreDataWorker.shared
    
    // MARK: - Model
    struct DisplayedCell {
        var name: String
        var desc: String?
        var image: Data?
        var url: String?
    }
    
    struct DisplayedEntry {
        var cover: UIImage
    }
    
    // MARK: - CRUD operations
    
    enum PlaylistList {
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
    
    enum FetchPlaylistAndConfigureCell {
        struct Request {
            var indexPath: IndexPath
            var cell: LibraryTableViewCell?
        }
        struct Response {
            var playlist: Playlist
            var indexPath: IndexPath
            var cell: LibraryTableViewCell?
        }
        struct ViewModel {
            var displayedPlaylist: DisplayedCell
            var indexPath: IndexPath
            var cell: LibraryTableViewCell?
        }
    }
    
    enum AlbumList {
        struct Request { }
        struct Response {
            var albums: [Album]
            var isError: Bool
            var message: String?
        }
        struct ViewModel {
            var albums: [Album]
            var isError: Bool
            var message: String?
        }
    }
    
    enum FetchAlbumAndConfigureCell {
        struct Request {
            var indexPath: IndexPath
            var cell: LibraryTableViewCell?
        }
        struct Response {
            var album: Album
            var indexPath: IndexPath
            var cell: LibraryTableViewCell?
        }
        struct ViewModel {
            var displayedAlbum: DisplayedCell
            var indexPath: IndexPath
            var cell: LibraryTableViewCell?
        }
    }
    
    enum CoverImage {
        struct Request {
            var url: String
            var type: LibrarySegmentKey
            var cell: LibraryTableViewCell
            var indexPath: IndexPath
        }
        struct Response {
            var entry: Entry
            var cell: LibraryTableViewCell
        }
        struct ViewModel {
            var displayedEntry: DisplayedEntry
            var cell: LibraryTableViewCell
        }
    }
    
    // MARK: - Library update lifecycle
    
    enum StartLibraryUpdates {
        struct Request { }
        struct Response { }
        struct ViewModel { }
    }
    
    enum StopLibraryUpdates {
        struct Request { }
        struct Response { }
        struct ViewModel { }
    }
}
