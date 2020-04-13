//
//  Playlist.swift
//  MusicPod
//
//  Created by Anderson Rodrigues on 18/03/2020.
//  Copyright © 2020 Anderson Rodrigues. All rights reserved.
//

import Foundation

struct Playlist: Decodable {
    var description: String?
    var id: String
    var images: [Image]?
    var name: String?
    var type: String?
}

struct PlaylistFull: Decodable {
    var followers: Follower?
    var tracks: Paging<PlaylistTrack>?
    var description: String?
    var id: String
    var images: [Image]?
    var name: String?
    var type: String?
}

struct PlaylistSimplified: Decodable {
    var tracks: PlaylistTrack?
    var description: String?
    var id: String
    var images: [Image]?
    var name: String?
    var type: String?
}
