//
//  Constants.swift
//  MusicPod
//
//  Created by Anderson Soares Rodrigues on 26/03/20.
//  Copyright © 2020 Anderson Soares Rodrigues. All rights reserved.
//

import Foundation

let reuseCategoryIdentifier = "reuseCategoryCell"

/// Enum Method to define types that can be used to make a request
enum Method: String {
    case get = "GET"
    case post = "POST"
}

/// Enum Endpoint defines all URL requests that the app can use to send
struct Constant {
    struct Server {
        static let baseURL = "https://api.spotify.com/v1/"
        static let accountURL = "https://accounts.spotify.com/"
        static let redirectURI = "musicpodapp://callback"
        static let authorizeURL = Constant.Server.accountURL + "authorize?client_id=\(Constant.clientKey.id)&response_type=code&redirect_uri=\(Constant.Server.redirectURI)&scope=user-read-recently-played%20user-library-read%20user-top-read%20playlist-read-private%20playlist-read-collaborative&state=81fFs29vq09"
    }
    
    struct Auth {
        static var authorizationToken: String?
        static var accessToken: String?
        static var refreshToken: String?
    }
    
    struct clientKey {
        static let id = ""
        static let secret = ""
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

enum ImageSize: Int {
    case large = 640
    case middle = 300
    case small = 64
}

struct Entry {
    var cover: Data
}

enum HomeSectionKeys: String {
    case recommendation = "recommendation"
    case new = "new"
    case featured = "featured"
}

enum LibrarySegmentKey: String {
    case album = "album"
    case playlist = "playlist"
}
