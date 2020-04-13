//
//  ErrorResponse.swift
//  VirtualMap
//
//  Created by Anderson Rodrigues on 17/03/2020.
//  Copyright © 2020 Anderson Rodrigues. All rights reserved.
//

import Foundation

struct ErrorResponse: Decodable {
    var status: Int?
    var message: String?
    var reason: String?
}

extension ErrorResponse: LocalizedError {
    var errorDescription: String? {
        return message
    }
}
