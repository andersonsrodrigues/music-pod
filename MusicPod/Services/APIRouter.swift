//
//  APIRouter.swift
//  MusicPod
//
//  Created by Anderson Soares Rodrigues on 26/03/20.
//  Copyright © 2020 Anderson Soares Rodrigues. All rights reserved.
//

import Foundation
import Alamofire

enum APIRouter: APIConfiguration {
    
    /// General
    case authorize
    case authorizationCode
    case refreshCode
    case posterImage(String)
    
    /// Album
    case getAlbum(String)
    
    /// Artist
    case getArtist(String)
    case getArtistTopTracks(String)
    
    /// Browse
    case getCategory(String)
    case getCategoryPlaylists(String)
    case getListCategories
    case getFeaturedPlaylists
    case getListNewReleases
    
    /// Library
    case getCurrentUserSavedAlbums
    
    /// Personalization
    case getUserTopArtistsAndTracks(String)
    
    /// Player
    case getCurrentUserRecentlyPlayedTracks
    
    /// Playlist
    case getListCurrentUserPlaylists
    case getPlaylist(String)
    
    /// Search
    case search(String)
    
    // MARK: - HTTP Method
    internal var method: HTTPMethod {
        switch self {
        case .authorize, .authorizationCode, .refreshCode:
            return .post
        case .getAlbum, .getArtist, .getArtistTopTracks, .getCategory, .getCategoryPlaylists, .getListCategories, .getFeaturedPlaylists, .getListNewReleases, .getCurrentUserSavedAlbums, .getUserTopArtistsAndTracks, .getCurrentUserRecentlyPlayedTracks, .getListCurrentUserPlaylists, .getPlaylist, .search, .posterImage:
            return .get
        }
    }
    
    // MARK: - Path
    internal var path: String {
        switch self {
        case .authorize:
            return "authorize?client_id=\(K.clientKey.id)&response_type=code&redirect_uri=\(K.Server.redirectURI)&scope=user-read-recently-played%20user-library-read%20user-top-read%20playlist-read-private%20playlist-read-collaborative&state=81fFs29vq09"
        case .authorizationCode:
            return "api/token"
        case .refreshCode:
            return "api/token"
        case .posterImage(let value):
            return value
        
        /// Album
        case .getAlbum(let value):
            return "albums/\(value)"
            
        /// Artist
        case .getArtist(let value):
            return "artists/\(value)"
        case .getArtistTopTracks(let value):
            return "artists/\(value)/top-tracks?country=from_token"
            
        /// Browse
        case .getCategory(let value):
            return "browse/categories/\(value)"
        case .getCategoryPlaylists(let value):
            return "browse/categories/\(value)/playlists"
        case .getListCategories:
            return "browse/categories"
        case .getFeaturedPlaylists:
            return "browse/featured-playlists"
        case .getListNewReleases:
            return "browse/new-releases"
            
        /// Library
        case .getCurrentUserSavedAlbums:
            return "me/albums"
            
        /// Personalization
        case .getUserTopArtistsAndTracks(let value):
            return "me/top/\(value)?limit=6"
            
        /// Player
        case .getCurrentUserRecentlyPlayedTracks:
            return "me/player/recently-played"

        /// Playlist
        case .getListCurrentUserPlaylists:
            return "me/playlists"
        case .getPlaylist(let value):
            return "playlists/\(value)"
        
        /// Search
        case .search(let query):
            return "search?q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&type=album,artist,playlist&limit=8"
        }
    }
    
    // MARK: - Parameters
    internal var parameters: Parameters? {
        switch self {
        case .authorizationCode:
            return [
                "code": "\(K.Auth.authorizationToken ?? "")",
                "grant_type": "authorization_code",
                "redirect_uri": "\(K.Server.redirectURI)"
            ]
        case .refreshCode:
            return [
                "refresh_token": "\(K.Auth.refreshToken ?? "")",
                "grant_type": "refresh_token"
            ]
        case .authorize, .getAlbum, .getArtist, .getArtistTopTracks, .getCategory, .getCategoryPlaylists, .getListCategories, .getFeaturedPlaylists, .getListNewReleases, .getCurrentUserSavedAlbums, .getUserTopArtistsAndTracks, .getCurrentUserRecentlyPlayedTracks, .getListCurrentUserPlaylists, .getPlaylist, .search, .posterImage:
            return nil
        }
    }
    
    // MARK: - URL
    internal var base: String {
        switch self {
        case .authorize, .authorizationCode, .refreshCode:
            return K.Server.accountURL
        case .getAlbum, .getArtist, .getArtistTopTracks, .getCategory, .getCategoryPlaylists, .getListCategories, .getFeaturedPlaylists, .getListNewReleases, .getCurrentUserSavedAlbums, .getUserTopArtistsAndTracks, .getCurrentUserRecentlyPlayedTracks, .getListCurrentUserPlaylists, .getPlaylist, .search:
            return K.Server.baseURL
        case .posterImage:
            return ""
        }
    }
    
    // MARK: - URLRequestConvertible
    func asURLRequest() throws -> URLRequest {
        let url = try base.asURL()
        
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        
        /// HTTP Method
        urlRequest.httpMethod = method.rawValue
        
        /// Parameters
        if let parameters = parameters {
            do {
                if let _ = K.Auth.accessToken {
                    urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
                } else {
                    urlRequest.httpBody = parameters.httpCompatible.data(using: .utf8)
                }
            } catch {
                throw error
            }
        }
        
        /// Common Headers
        if let token = K.Auth.accessToken {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: HTTPHeaderField.authentication.rawValue)
            urlRequest.setValue(ContentType.json.rawValue, forHTTPHeaderField: HTTPHeaderField.acceptType.rawValue)
            urlRequest.setValue(ContentType.json.rawValue, forHTTPHeaderField: HTTPHeaderField.contentType.rawValue)
        } else {
            let data = "\(K.clientKey.id):\(K.clientKey.secret)".data(using: .utf8)
            
            urlRequest.setValue("Basic \(data!.base64EncodedString())", forHTTPHeaderField: HTTPHeaderField.authentication.rawValue)
            urlRequest.setValue(ContentType.json.rawValue, forHTTPHeaderField: HTTPHeaderField.acceptType.rawValue)
            urlRequest.setValue(ContentType.urlencoded.rawValue, forHTTPHeaderField: HTTPHeaderField.contentType.rawValue)
        }
        
        return urlRequest
    }
}

extension Dictionary where Key == String {
    
    var httpCompatible: String {
        return String(
            self.reduce("") { "\($0)&\($1.key)=\($1.value)" }
                .replacingOccurrences(of: " ", with: "+")
                .dropFirst()
        )
    }
}
