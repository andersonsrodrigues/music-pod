//
//  CategoriesResponse.swift
//  MusicPod
//
//  Created by Anderson Rodrigues on 18/03/2020.
//  Copyright © 2020 Anderson Rodrigues. All rights reserved.
//

import Foundation

struct CategoriesResponse<T: Decodable>: Decodable {
    var categories: Paging<T>
}
