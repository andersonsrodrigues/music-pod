//
//  Album.swift
//  MusicPod
//
//  Created by Anderson Rodrigues on 19/03/2020.
//  Copyright © 2020 Anderson Rodrigues. All rights reserved.
//

import Foundation

enum AlbumType: String, Decodable {
    case album
    case single
    case compilation
}

struct AlbumData: Decodable {
    var albumType: AlbumType?
    var artists: [ArtistData]?
    var id: String?
    var images: [ImageData]?
    var name: String
    var type: String?
    var label: String?
    var tracks: Paging<TrackData>?
    var session: String?
    
    enum CodingKeys: String, CodingKey {
        case albumType = "album_type"
        case artists, id, images, name, type, label, tracks
    }
    
    func getAllArtists() -> String {
        var names = [String]()
        
        if let artists = artists {
            for artist in artists {
                if let name = artist.name {
                    names.append(name)
                }
            }
        }
        
        return names.joined(separator: ",")
    }
}
