//
//  Playlist.swift
//  MusicPod
//
//  Created by Anderson Rodrigues on 18/03/2020.
//  Copyright © 2020 Anderson Rodrigues. All rights reserved.
//

import Foundation

struct PlaylistData: Decodable {
    var description: String?
    var id: String
    var images: [ImageData]?
    var name: String?
    var type: String?
    var session: String?
}

struct PlaylistFullData: Decodable {
    var followers: Follower?
    var tracks: Paging<PlaylistTrack>?
    var description: String?
    var id: String
    var images: [ImageData]?
    var name: String?
    var type: String?
    var session: String?
}

struct PlaylistSimplifiedData: Decodable {
    var tracks: PlaylistTrack?
    var description: String?
    var id: String
    var images: [ImageData]?
    var name: String?
    var type: String?
    var session: String?
}
