//
//  HomeModels.swift
//  MusicPod
//
//  Created by Anderson Soares Rodrigues on 26/03/20.
//  Copyright (c) 2020 Anderson Soares Rodrigues. All rights reserved.
//

import UIKit

struct Entry {
    var name: String
    var cover: UIImage
}

enum Home {
    struct DisplayedEntry {
        var name: String
        var cover: UIImage
    }
    
    enum TopArtists {
        struct Request {}
        struct Response {
            var artists: [Artist]
        }
        struct ViewModel
        {
            var artists: [Artist]
        }
    }
    
    enum NewRelease {
        struct Request {}
        struct Response {
            var releases: [Album]
        }
        struct ViewModel
        {
            var releases: [Album]
        }
    }
    
    enum FeaturePlaylists {
        struct Request {}
        struct Response {
            var playlists: [PlaylistSimplified]
        }
        struct ViewModel {
            var playlists: [PlaylistSimplified]
        }
    }
    
    enum SetCover {
        struct Request {
            var url: String
            var indexPath: IndexPath
        }
        struct Response {
            var entry: Entry
            var indexPath: IndexPath
        }
        struct ViewModel {
            var displayedEntry: DisplayedEntry
            var indexPath: IndexPath
        }
    }
}
