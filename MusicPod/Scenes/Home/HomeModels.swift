//
//  HomeModels.swift
//  MusicPod
//
//  Created by Anderson Soares Rodrigues on 26/03/20.
//  Copyright (c) 2020 Anderson Soares Rodrigues. All rights reserved.
//

import UIKit

enum HomeModel {
    
    // MARK: - External Workers
    
    static var artistWorker = ArtistCoreDataWorker.shared
    static var albumWorker = AlbumCoreDataWorker.shared
    static var playlistWorker = PlaylistCoreDataWorker.shared
    
    // MARK: - Model
    
    struct DisplayedCell {
        var name: String
        var image: Data?
        var url: String?
    }
    
    struct DisplayedEntry {
        var cover: UIImage
    }
    
    // MARK: - CRUD operations
    
    enum TopArtists {
        struct Request { }
        struct Response {
            var artists: [Artist]
            var isError: Bool
            var message: String?
        }
        struct ViewModel {
            var artists: [Artist]
            var isError: Bool
            var message: String?
        }
    }
    
    enum FetchTopArtistAndConfigureCell {
        struct Request {
            var indexPath: IndexPath
            var cell: HorizontalPlaylistCollectionViewCell?
        }
        struct Response {
            var artist: Artist
            var cell: HorizontalPlaylistCollectionViewCell?
            var indexPath: IndexPath
        }
        struct ViewModel {
            var displayedArtist: DisplayedCell
            var cell: HorizontalPlaylistCollectionViewCell?
            var indexPath: IndexPath
        }
    }
    
    enum NewRelease {
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
    
    enum FetchNewReleaseAndConfigureCell {
        struct Request {
            var indexPath: IndexPath
            var cell: HorizontalPlaylistCollectionViewCell?
        }
        struct Response {
            var album: Album
            var cell: HorizontalPlaylistCollectionViewCell?
            var indexPath: IndexPath
        }
        struct ViewModel {
            var displayedAlbum: DisplayedCell
            var cell: HorizontalPlaylistCollectionViewCell?
            var indexPath: IndexPath
        }
    }
    
    enum FeaturePlaylists {
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
    
    enum FetchFeaturePlaylistsAndConfigureCell {
        struct Request {
            var indexPath: IndexPath
            var cell: HorizontalPlaylistCollectionViewCell?
        }
        struct Response {
            var playlist: Playlist
            var cell: HorizontalPlaylistCollectionViewCell?
            var indexPath: IndexPath
        }
        struct ViewModel {
            var displayedPlaylist: DisplayedCell
            var cell: HorizontalPlaylistCollectionViewCell?
            var indexPath: IndexPath
        }
    }
    
    enum CoverImage {
        struct Request {
            var url: String
            var type: HomeSectionKeys
            var indexPath: IndexPath
            var cell: HorizontalPlaylistCollectionViewCell
        }
        struct Response {
            var entry: Entry
            var cell: HorizontalPlaylistCollectionViewCell
        }
        struct ViewModel {
            var displayedEntry: DisplayedEntry
            var cell: HorizontalPlaylistCollectionViewCell
        }
    }
    
    // MARK: - Home update lifecycle
    
    enum StartHomeUpdates {
        struct Request { }
        struct Response { }
        struct ViewModel { }
    }
    
    enum StopHomeUpdates {
        struct Request { }
        struct Response { }
        struct ViewModel { }
    }
}
