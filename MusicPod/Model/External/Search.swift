//
//  Search.swift
//  MusicPod
//
//  Created by Anderson Rodrigues on 20/03/2020.
//  Copyright © 2020 Anderson Rodrigues. All rights reserved.
//

import Foundation

struct Search: Decodable {
    var id: String
    var name: String
    var type: String?
    var images: [ImageData]?
}
