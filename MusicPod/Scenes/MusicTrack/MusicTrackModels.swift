//
//  MusicTrackModels.swift
//  MusicPod
//
//  Created by Anderson Rodrigues on 15/04/2020.
//  Copyright (c) 2020 Anderson Soares Rodrigues. All rights reserved.
//

import UIKit

enum MusicTrackModel {
    
    // MARK: - External Workers
    
    static var playlistWorker = PlaylistCoreDataWorker.shared
    static var albumWorker = AlbumCoreDataWorker.shared
    static var artistWorker = ArtistCoreDataWorker.shared
    static var trackWorker = TrackCoreDataWorker.shared
    
    // MARK: - Model
    struct DisplayedDescCell {
        var name: String?
        var desc: String?
        var image: Data?
        var url: String?
    }
    
    struct DisplayedTrackCell {
        var name: String
        var artistName: String
    }
    
    struct DisplayedImage {
        var cover: UIImage
    }
    
    // MARK: - CRUD operations
    
    enum List {
		struct Request { }
		struct Response {
            var tracks: [Track]
            var error: String?
		}
		struct ViewModel {
            var tracks: [Track]
            var error: String?
		}
	}
    
    enum Music {
        struct Request {
            var indexPath: IndexPath
        }
        struct Response {
            var available: Bool
        }
        struct ViewModel {
            var available: Bool
        }
    }
    
    enum FetchListAndConfigureCell {
        struct Request {
            var indexPath: IndexPath
            var cell: TrackTableViewCell?
        }
        struct Response {
            var track: Track
            var cell: TrackTableViewCell?
            var indexPath: IndexPath
        }
        struct ViewModel {
            var displayedTrack: DisplayedTrackCell
            var cell: TrackTableViewCell?
            var indexPath: IndexPath
        }
    }
    
    // MARK: - Playlist CRUD operations
    
    enum PlaylistData {
        struct Request {
            var id: String
        }
        struct Response {
            var playlist: Playlist?
            var error: String?
        }
        struct ViewModel {
            var playlist: Playlist?
            var error: String?
        }
    }
    
    // MARK: - Album CRUD operations
    
    enum AlbumData {
        struct Request {
            var id: String
        }
        struct Response {
            var album: Album?
            var error: String?
        }
        struct ViewModel {
            var album: Album?
            var error: String?
        }
    }
    
    // MARK: - Artist CRUD operations
    
    enum ArtistData {
        struct Request {
            var id: String
        }
        struct Response {
            var artist: Artist?
            var error: String?
        }
        struct ViewModel {
            var artist: Artist?
            var error: String?
        }
    }
    
    enum FetchMusicDescAndConfigureCell {
        struct Request {
            var indexPath: IndexPath
            var cell: MusicDescTableViewCell?
        }
        struct Response {
            var playlist: Playlist?
            var album: Album?
            var artist: Artist?
            var cell: MusicDescTableViewCell?
            var indexPath: IndexPath
        }
        struct ViewModel {
            var displayedMusicDesc: DisplayedDescCell
            var cell: MusicDescTableViewCell?
            var indexPath: IndexPath
        }
    }
    
    enum CoverImage {
        struct Request {
            var url: String
            var cell: MusicDescTableViewCell
            var indexPath: IndexPath
        }
        struct Response {
            var entry: Entry
            var cell: MusicDescTableViewCell
        }
        struct ViewModel {
            var displayedEntry: DisplayedImage?
            var cell: MusicDescTableViewCell
        }
    }
    
    // MARK: - Sound
    
    enum PlayingState {
        case playing, notPlaying
    }
    
    enum FetchSound {
        struct Request {
            var indexPath: IndexPath
            var cell: TrackTableViewCell
        }
        struct Response {
            var music: Data?
            var indexPath: IndexPath?
            var cell: TrackTableViewCell
            var error: String?
        }
        struct ViewModel {
            var indexPath: IndexPath?
            var cell: TrackTableViewCell
            var error: String?
        }
    }
    
    // MARK: - Track update lifecycle
    
    enum StartTrackUpdates {
        struct Request { }
        struct Response { }
        struct ViewModel { }
    }
    
    enum StopTrackUpdates {
        struct Request { }
        struct Response { }
        struct ViewModel { }
    }
}
