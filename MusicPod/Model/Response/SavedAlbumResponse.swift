//
//  SavedAlbumResponse.swift
//  MusicPod
//
//  Created by Anderson Rodrigues on 20/03/2020.
//  Copyright © 2020 Anderson Rodrigues. All rights reserved.
//

import Foundation

struct SavedAlbumResponse: Decodable {
    var album: Album?
    
    enum CodingKeys: String, CodingKey {
        case album
    }
}
