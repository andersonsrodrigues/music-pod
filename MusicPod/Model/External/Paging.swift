//
//  Paging.swift
//  MusicPod
//
//  Created by Anderson Rodrigues on 18/03/2020.
//  Copyright © 2020 Anderson Rodrigues. All rights reserved.
//

import Foundation

struct Paging<T: Decodable>: Decodable {
    
    var items: [T]
    
}
