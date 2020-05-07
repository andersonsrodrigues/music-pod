//
//  ImageData.swift
//  MusicPod
//
//  Created by Anderson Rodrigues on 13/04/2020.
//  Copyright © 2020 Anderson Soares Rodrigues. All rights reserved.
//

import Foundation

struct ImageData: Decodable {
    let url: String?
    let width: Int?
    let height: Int?
    
    func getUrlBySize(size: ImageSize) -> String? {
        if let url = url {
            if width == size.rawValue && height == size.rawValue {
                return url
            }
        }
        
        return nil
    }
}

extension ImageData: Equatable {
    static func == (lhs: ImageData, rhs: ImageData) -> Bool {
        return lhs.width == rhs.width
            && lhs.height == rhs.height
    }
}
