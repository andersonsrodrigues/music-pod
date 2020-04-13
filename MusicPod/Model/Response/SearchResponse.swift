//
//  SearchResponse.swift
//  MusicPod
//
//  Created by Anderson Rodrigues on 20/03/2020.
//  Copyright © 2020 Anderson Rodrigues. All rights reserved.
//

import Foundation

struct SearchResponse: Decodable {
    var artists: Paging<Search>?
    var albums: Paging<Search>?
    var playlists: Paging<Search>?
}
