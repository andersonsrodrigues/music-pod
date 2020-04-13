//
//  Constants.swift
//  MusicPod
//
//  Created by Anderson Soares Rodrigues on 26/03/20.
//  Copyright © 2020 Anderson Soares Rodrigues. All rights reserved.
//

import Foundation

struct K {
    struct Server {
        static let baseURL = "https://api.spotify.com/v1/"
        static let accountURL = "https://accounts.spotify.com/"
        static let redirectURI = "musicpodapp://callback"
        static let authorizeURL = K.Server.accountURL + "authorize?client_id=\(K.clientKey.id)&response_type=code&redirect_uri=\(K.Server.redirectURI)&scope=user-read-recently-played%20user-library-read%20user-top-read%20playlist-read-private%20playlist-read-collaborative&state=81fFs29vq09"
    }
    
    struct Auth {
        static var authorizationToken: String?
        static var accessToken: String?
        static var refreshToken: String?
    }
    
    struct clientKey {
        static let id = "420c536db4d94c6dba9e1938ae074512"
        static let secret = "4f8fc1e47bc74f35aefb2fa064bd6f72"
    }
    
    struct APIParameterKey {
        static let password = "password"
        static let email = "email"
    }
}

enum HTTPHeaderField: String {
    case authentication = "Authorization"
    case contentType = "Content-Type"
    case acceptType = "Accept"
    case acceptEncoding = "Accept-Encoding"
}

enum ContentType: String {
    case json = "application/json"
    case urlencoded = "application/x-www-form-urlencoded"
}
