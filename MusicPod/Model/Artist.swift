//
//  Artist.swift
//  MusicPod
//
//  Created by Anderson Rodrigues on 18/03/2020.
//  Copyright © 2020 Anderson Rodrigues. All rights reserved.
//

import Foundation

struct Artist: Decodable {
    var id: String
    var name: String?
    var type: String?
    var images: [Image]?
    var followers: Follower?
    var popularity: Int?
}
