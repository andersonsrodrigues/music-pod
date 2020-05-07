//
//  PlayHistory.swift
//  MusicPod
//
//  Created by Anderson Rodrigues on 19/03/2020.
//  Copyright © 2020 Anderson Rodrigues. All rights reserved.
//

import Foundation

struct PlayHistory: Decodable {
    var track: TrackData?
    var context: Context?
}
