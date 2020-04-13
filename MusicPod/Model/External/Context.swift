//
//  Context.swift
//  MusicPod
//
//  Created by Anderson Rodrigues on 19/03/2020.
//  Copyright © 2020 Anderson Rodrigues. All rights reserved.
//

import Foundation

enum ContextType: String, Decodable {
    case artist
    case playlist
    case album
}

struct Context: Decodable {
    var type: ContextType
}
