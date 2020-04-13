//
//  Image.swift
//  MusicPod
//
//  Created by Anderson Rodrigues on 18/03/2020.
//  Copyright © 2020 Anderson Rodrigues. All rights reserved.
//

import Foundation

enum ImageSize: Int {
    case large = 640
    case middle = 300
    case small = 64
}

struct Image: Decodable {
    var height: Int?
    var url: String?
    var width: Int?
    
    func getUrlBySize(size: ImageSize) -> String? {
        if let url = url {
            if width == size.rawValue && height == size.rawValue {
                return url
            }
        }
        
        return nil
    }
}

extension Image: Equatable {
    static func == (lhs: Image, rhs: Image) -> Bool {
        return lhs.width == rhs.width
            && lhs.height == rhs.height
    }
}
