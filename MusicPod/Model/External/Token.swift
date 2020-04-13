//
//  TokenResponse.swift
//  MusicPod
//
//  Created by Anderson Rodrigues on 17/03/2020.
//  Copyright © 2020 Anderson Rodrigues. All rights reserved.
//

import Foundation

struct Token: Decodable {
    var accessToken: String
    var tokenType: String
    var scope: String
    var expiresIn: Double
    var refreshToken: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case scope
        case expiresIn = "expires_in"
        case refreshToken = "refresh_token"
    }
}
