//
//  PlaylistsResponse.swift
//  MusicPod
//
//  Created by Anderson Rodrigues on 18/03/2020.
//  Copyright © 2020 Anderson Rodrigues. All rights reserved.
//

import Foundation

struct PlaylistsResponse<T: Decodable>: Decodable {
    var playlists: Paging<T>
}
