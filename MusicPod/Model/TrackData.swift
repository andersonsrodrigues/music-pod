//
//  Track.swift
//  MusicPod
//
//  Created by Anderson Rodrigues on 19/03/2020.
//  Copyright © 2020 Anderson Rodrigues. All rights reserved.
//

import Foundation

struct TrackData: Decodable {
    var artists: [ArtistData]
    var id: String?
    var name: String?
    var previewUrl: String?
    var type: String?
    var album: AlbumData?
    var popularity: Int?
    
    enum CodingKeys: String, CodingKey {
        case artists, id, name, type, album, popularity
        case previewUrl = "preview_url"
    }
    
    func getAllArtists() -> String {
        var names = [String]()
        
        for artist in artists {
            if let name = artist.name {
                names.append(name)
            }
        }
        
        return names.joined(separator: ",")
    }
}
