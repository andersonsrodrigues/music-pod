//
//  APIClient.swift
//  MusicPod
//
//  Created by Anderson Soares Rodrigues on 26/03/20.
//  Copyright © 2020 Anderson Soares Rodrigues. All rights reserved.
//

import Foundation

final class APIClient {
    
    // MARK:  General
    class func requestTokens(completion: @escaping (Bool, Error?) -> Void) {
        
        APIService.performRequest(from: APIRouter.authorizationCode, responseType: TokenResponse.self) { response in
            switch response {
                case .success(let value):
                    
                    Constant.Auth.accessToken = value.accessToken
                    Constant.Auth.refreshToken = value.refreshToken

                    UserDefaults.standard.set(value.accessToken, forKey: "accessToken")
                    UserDefaults.standard.set(value.refreshToken, forKey: "refreshToken")
                    
                    return completion(true, nil)
                case .failure(let error):
                    return completion(false, error)
            }
        }
    }
    
    class func refreshToken(completion: @escaping(Bool, Error?) -> Void) {
        Constant.Auth.accessToken = nil
        
        APIService.performRequest(from: APIRouter.refreshCode, responseType: TokenResponse.self) { response in
            switch response {
                case .success(let value):
                    Constant.Auth.accessToken = value.accessToken

                    UserDefaults.standard.set(value.accessToken, forKey: "accessToken")
                    return completion(true, nil)
                case .failure(let error):
                    return completion(false, error)
            }
        }
    }
    
    class func downloadMusic(path: URL, completion: @escaping(Data?, Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: path) { (data, response, error) in
            DispatchQueue.main.async {
                completion(data, error)
            }
        }
        task.resume()
    }
    
    class func downloadPosterImage(path: String, completion: @escaping (Data?, Error?) -> Void) {
        do {
            let task = URLSession.shared.dataTask(with: try path.asURL()) { data, response, error in
                DispatchQueue.main.async {
                    completion(data, error)
                }
            }
            task.resume()
        } catch {
            fatalError("Error to handle the data task on download poster image")
        }
    }
    
    // MARK: Album
    class func getAlbum(with id: String, completion: @escaping(AlbumData?, Error?) -> Void) {
        let url = APIRouter.getAlbum(id)
        let model = AlbumData.self
        
        APIService.performRequest(from: url, responseType: model) { (response) in
            switch response {
            case .success(let value):
                return completion(value, nil)
            case .failure(let error):
                guard let errorResult = error as? CustomNSError else {
                    return completion(nil, error)
                }
                
                if errorResult.errorCode != 401 {
                    completion(nil, error)
                }
                
                APIClient.refreshToken { (result, error) in
                    if result {
                        APIService.performRequest(from: url, responseType: model) { (response) in
                            switch response {
                            case .success(let value):
                                return completion(value, nil)
                            case .failure(let error):
                                return completion(nil, error)
                            }
                        }
                    } else {
                        Constant.Auth.accessToken = nil
                        Constant.Auth.authorizationToken = nil
                        Constant.Auth.refreshToken = nil

                        completion(nil, error)
                    }
                }
            }
        }
    }
    
    class func getAlbumTracks(with id: String, completion: @escaping([TrackData], Error?) -> Void) {
        let url = APIRouter.getAlbumTracks(id)
        let model = Paging<TrackData>.self
        
        APIService.performRequest(from: url, responseType: model) { (response) in
            switch response {
            case .success(let value):
                return completion(value.items, nil)
            case .failure(let error):
                guard let errorResult = error as? CustomNSError else {
                    return completion([], error)
                }
                
                if errorResult.errorCode != 401 {
                    completion([], error)
                }
                
                APIClient.refreshToken { (result, error) in
                    if result {
                        APIService.performRequest(from: url, responseType: model) { (response) in
                            switch response {
                            case .success(let value):
                                return completion(value.items, nil)
                            case .failure(let error):
                                return completion([], error)
                            }
                        }
                    } else {
                        Constant.Auth.accessToken = nil
                        Constant.Auth.authorizationToken = nil
                        Constant.Auth.refreshToken = nil

                        completion([], error)
                    }
                }
            }
        }
    }
    
    // MARK: Artists
    class func getArtist(with id: String, completion: @escaping(ArtistData?, Error?) -> Void) {
        let url = APIRouter.getArtist(id)
        let model = ArtistData.self
        
        APIService.performRequest(from: url, responseType: model) { (response) in
            switch response {
            case .success(let value):
                return completion(value, nil)
            case .failure(let error):
                guard let errorResult = error as? CustomNSError else {
                    return completion(nil, error)
                }
                
                if errorResult.errorCode != 401 {
                    completion(nil, error)
                }
                
                APIClient.refreshToken { (result, error) in
                    if result {
                        APIService.performRequest(from: url, responseType: model) { (response) in
                            switch response {
                            case .success(let value):
                                return completion(value, nil)
                            case .failure(let error):
                                return completion(nil, error)
                            }
                        }
                    } else {
                        Constant.Auth.accessToken = nil
                        Constant.Auth.authorizationToken = nil
                        Constant.Auth.refreshToken = nil

                        completion(nil, error)
                    }
                }
            }
        }
    }
    
    class func getArtistTopTracks(with id: String, completion: @escaping([TrackData], Error?) -> Void) {
        let url = APIRouter.getArtistTopTracks(id)
        let model = TracksResponse.self
        
        APIService.performRequest(from: url, responseType: model) { (response) in
            switch response {
            case .success(let value):
                return completion(value.tracks, nil)
            case .failure(let error):
                guard let errorResult = error as? CustomNSError else {
                    return completion([], error)
                }
                
                if errorResult.errorCode != 401 {
                    completion([], error)
                }
                
                APIClient.refreshToken { (result, error) in
                    if result {
                        APIService.performRequest(from: url, responseType: model) { (response) in
                            switch response {
                            case .success(let value):
                                return completion(value.tracks, nil)
                            case .failure(let error):
                                return completion([], error)
                            }
                        }
                    } else {
                        Constant.Auth.accessToken = nil
                        Constant.Auth.authorizationToken = nil
                        Constant.Auth.refreshToken = nil

                        completion([], error)
                    }
                }
            }
        }
    }
    
    // MARK: Browse
    class func getCategory(with id: String, completion: @escaping(CategoryData?, Error?) -> Void) {
        let url = APIRouter.getCategory(id)
        let model = CategoryData.self
        
        APIService.performRequest(from: url, responseType: model) { (response) in
            switch response {
            case .success(let value):
                return completion(value, nil)
            case .failure(let error):
                guard let errorResult = error as? CustomNSError else {
                    return completion(nil, error)
                }
                
                if errorResult.errorCode != 401 {
                    completion(nil, error)
                }
                
                APIClient.refreshToken { (result, error) in
                    if result {
                        APIService.performRequest(from: url, responseType: model) { (response) in
                            switch response {
                            case .success(let value):
                                return completion(value, nil)
                            case .failure(let error):
                                return completion(nil, error)
                            }
                        }
                    } else {
                        Constant.Auth.accessToken = nil
                        Constant.Auth.authorizationToken = nil
                        Constant.Auth.refreshToken = nil

                        completion(nil, error)
                    }
                }
            }
        }
    }
    
    class func getCategoryPlaylists(on category: String, completion: @escaping([PlaylistSimplifiedData], Error?) -> Void) {
        let url = APIRouter.getCategoryPlaylists(category)
        let model = PlaylistsResponse<PlaylistSimplifiedData>.self
        
        APIService.performRequest(from: url, responseType: model) { (response) in
            switch response {
            case .success(let value):
                return completion(value.playlists.items, nil)
            case .failure(let error):
                guard let errorResult = error as? CustomNSError else {
                    return completion([], error)
                }
                
                if errorResult.errorCode != 401 {
                    completion([], error)
                }
                
                APIClient.refreshToken { (result, error) in
                    if result {
                        APIService.performRequest(from: url, responseType: model) { (response) in
                            switch response {
                            case .success(let value):
                                return completion(value.playlists.items, nil)
                            case .failure(let error):
                                return completion([], error)
                            }
                        }
                    } else {
                        Constant.Auth.accessToken = nil
                        Constant.Auth.authorizationToken = nil
                        Constant.Auth.refreshToken = nil

                        completion([], error)
                    }
                }
            }
        }
    }
    
    class func getListOfCategories(completion: @escaping([CategoryData], Error?) -> Void) {
        let url = APIRouter.getListCategories
        let model = CategoriesResponse<CategoryData>.self
        
        APIService.performRequest(from: url, responseType: model) { (response) in
            switch response {
            case .success(let value):
                return completion(value.categories.items, nil)
            case .failure(let error):
                guard let errorResult = error as? CustomNSError else {
                    return completion([], error)
                }
                
                if errorResult.errorCode != 401 {
                    completion([], error)
                }
                
                APIClient.refreshToken { (result, error) in
                    if result {
                        APIService.performRequest(from: url, responseType: model) { (response) in
                            switch response {
                            case .success(let value):
                                return completion(value.categories.items, nil)
                            case .failure(let error):
                                return completion([], error)
                            }
                        }
                    } else {
                        Constant.Auth.accessToken = nil
                        Constant.Auth.authorizationToken = nil
                        Constant.Auth.refreshToken = nil

                        completion([], error)
                    }
                }
            }
        }
    }
    
    class func getListFeaturedPlaylist(completion: @escaping([PlaylistSimplifiedData], Error?) -> Void) {
        let url = APIRouter.getFeaturedPlaylists
        let model = PlaylistsResponse<PlaylistSimplifiedData>.self
        
        APIService.performRequest(from: url, responseType: model) { (response) in
            switch response {
            case .success(let value):
                return completion(value.playlists.items, nil)
            case .failure(let error):
                guard let errorResult = error as? CustomNSError else {
                    return completion([], error)
                }
                
                if errorResult.errorCode != 401 {
                    completion([], error)
                }
                
                APIClient.refreshToken { (result, error) in
                    if result {
                        APIService.performRequest(from: url, responseType: model) { (response) in
                            switch response {
                            case .success(let value):
                                return completion(value.playlists.items, nil)
                            case .failure(let error):
                                return completion([], error)
                            }
                        }
                    } else {
                        Constant.Auth.accessToken = nil
                        Constant.Auth.authorizationToken = nil
                        Constant.Auth.refreshToken = nil

                        completion([], error)
                    }
                }
            }
        }
    }
    
    class func getListNewReleases(completion: @escaping([AlbumData], Error?) -> Void) {
        let url = APIRouter.getListNewReleases
        let model = AlbumsResponse<AlbumData>.self
        
        APIService.performRequest(from: url, responseType: model) { (response) in
            switch response {
            case .success(let value):
                return completion(value.albums.items, nil)
            case .failure(let error):
                guard let errorResult = error as? CustomNSError else {
                    return completion([], error)
                }
                
                if errorResult.errorCode != 401 {
                    completion([], error)
                }

                APIClient.refreshToken { (result, error) in
                    if result {
                        APIService.performRequest(from: url, responseType: model) { (response) in
                            switch response {
                            case .success(let value):
                                return completion(value.albums.items, nil)
                            case .failure(let error):
                                return completion([], error)
                            }
                        }
                    } else {
                        Constant.Auth.accessToken = nil
                        Constant.Auth.authorizationToken = nil
                        Constant.Auth.refreshToken = nil

                        completion([], error)
                    }
                }
            }
        }
    }
    
    // MARK: Library
    class func getCurrentUserSavedAlbums(completion: @escaping([SavedAlbumResponse], Error?) -> Void) {
        let url = APIRouter.getCurrentUserSavedAlbums
        let model = Paging<SavedAlbumResponse>.self
        
        APIService.performRequest(from: url, responseType: model) { (response) in
            switch response {
            case .success(let value):
                return completion(value.items, nil)
            case .failure(let error):
                guard let errorResult = error as? CustomNSError else {
                    return completion([], error)
                }
                
                if errorResult.errorCode != 401 {
                    completion([], error)
                }

                APIClient.refreshToken { (result, error) in
                    if result {
                        APIService.performRequest(from: url, responseType: model) { (response) in
                            switch response {
                            case .success(let value):
                                return completion(value.items, nil)
                            case .failure(let error):
                                return completion([], error)
                            }
                        }
                    } else {
                        Constant.Auth.accessToken = nil
                        Constant.Auth.authorizationToken = nil
                        Constant.Auth.refreshToken = nil

                        completion([], error)
                    }
                }
            }
        }
    }
    
    // MARK: Personalization
    class func getUserTopArtistsAndTracks(as type: String, completion: @escaping([ArtistData], Error?) -> Void) {
        let url = APIRouter.getUserTopArtistsAndTracks(type)
        let model = Paging<ArtistData>.self
        
        APIService.performRequest(from: url, responseType: model) { (response) in
            switch response {
            case .success(let value):
                return completion(value.items, nil)
            case .failure(let error):
                guard let errorResult = error as? CustomNSError else {
                    return completion([], error)
                }
                
                if errorResult.errorCode != 401 {
                    completion([], error)
                }

                APIClient.refreshToken { (result, error) in
                    if result {
                        APIService.performRequest(from: url, responseType: model) { (response) in
                            switch response {
                            case .success(let value):
                                return completion(value.items, nil)
                            case .failure(let error):
                                return completion([], error)
                            }
                        }
                    } else {
                        Constant.Auth.accessToken = nil
                        Constant.Auth.authorizationToken = nil
                        Constant.Auth.refreshToken = nil

                        completion([], error)
                    }
                }
            }
        }
    }
    
    // MARK: Player
    class func getCurrentUserRecentlyPlayedTracks(completion: @escaping([PlayHistory], Error?) -> Void) {
        let url = APIRouter.getCurrentUserRecentlyPlayedTracks
        let model = Paging<PlayHistory>.self
        
        APIService.performRequest(from: url, responseType: model) { (response) in
            switch response {
            case.success(let value):
                return completion(value.items, nil)
            case .failure(let error):
                guard let errorResult = error as? CustomNSError else {
                    return completion([], error)
                }
                
                if errorResult.errorCode != 401 {
                    completion([], error)
                }

                APIClient.refreshToken { (result, error) in
                    if result {
                        APIService.performRequest(from: url, responseType: model) { (response) in
                            switch response {
                            case .success(let value):
                                return completion(value.items, nil)
                            case .failure(let error):
                                return completion([], error)
                            }
                        }
                    } else {
                        Constant.Auth.accessToken = nil
                        Constant.Auth.authorizationToken = nil
                        Constant.Auth.refreshToken = nil

                        completion([], error)
                    }
                }
            }
        }
    }
    
    // MARK: Playlist
    class func getListCurrentUserPlaylist(completion: @escaping([PlaylistSimplifiedData], Error?) -> Void) {
        let url = APIRouter.getListCurrentUserPlaylists
        let model = Paging<PlaylistSimplifiedData>.self
        
        APIService.performRequest(from: url, responseType: model) { (response) in
            switch response {
            case .success(let value):
                return completion(value.items, nil)
            case .failure(let error):
                guard let errorResult = error as? CustomNSError else {
                    return completion([], error)
                }
                
                if errorResult.errorCode != 401 {
                    completion([], error)
                }

                APIClient.refreshToken { (result, error) in
                    if result {
                        APIService.performRequest(from: url, responseType: model) { (response) in
                            switch response {
                            case .success(let value):
                                return completion(value.items, nil)
                            case .failure(let error):
                                return completion([], error)
                            }
                        }
                    } else {
                        Constant.Auth.accessToken = nil
                        Constant.Auth.authorizationToken = nil
                        Constant.Auth.refreshToken = nil

                        completion([], error)
                    }
                }
            }
        }
    }
    
    class func getPlaylist(with id: String, completion: @escaping(PlaylistFullData?, Error?) -> Void) {
        let url = APIRouter.getPlaylist(id)
        let model = PlaylistFullData.self
        
        APIService.performRequest(from: url, responseType: model) { (response) in
            switch response {
            case .success(let value):
                return completion(value, nil)
            case .failure(let error):
                guard let errorResult = error as? CustomNSError else {
                    return completion(nil, error)
                }
                
                if errorResult.errorCode != 401 {
                    completion(nil, error)
                }

                APIClient.refreshToken { (result, error) in
                    if result {
                        APIService.performRequest(from: url, responseType: model) { (response) in
                            switch response {
                            case .success(let value):
                                return completion(value, nil)
                            case .failure(let error):
                                return completion(nil, error)
                            }
                        }
                    } else {
                        Constant.Auth.accessToken = nil
                        Constant.Auth.authorizationToken = nil
                        Constant.Auth.refreshToken = nil

                        completion(nil, error)
                    }
                }
            }
        }
    }
    
    class func getPlaylistTracks(with id: String, completion: @escaping([PlaylistTrack], Error?) -> Void) {
        let url = APIRouter.getPlaylistTracks(id)
        let model = Paging<PlaylistTrack>.self
        
        APIService.performRequest(from: url, responseType: model) { (response) in
            switch response {
            case .success(let value):
                return completion(value.items, nil)
            case .failure(let error):
                guard let errorResult = error as? CustomNSError else {
                    return completion([], error)
                }
                
                if errorResult.errorCode != 401 {
                    completion([], error)
                }

                APIClient.refreshToken { (result, error) in
                    if result {
                        APIService.performRequest(from: url, responseType: model) { (response) in
                            switch response {
                            case .success(let value):
                                return completion(value.items, nil)
                            case .failure(let error):
                                return completion([], error)
                            }
                        }
                    } else {
                        Constant.Auth.accessToken = nil
                        Constant.Auth.authorizationToken = nil
                        Constant.Auth.refreshToken = nil

                        completion([], error)
                    }
                }
            }
        }
    }
    
    // MARK: Search
    class func search(query: String, completion: @escaping(SearchResponse?, Error?) -> Void) -> URLSessionDataTask{
        let url = APIRouter.search(query)
        let model = SearchResponse.self
        
        let task = APIService.performRequest(from: url, responseType: model) { (response) in
            switch response {
            case .success(let value):
                return completion(value, nil)
            case .failure(let error):
                guard let errorResult = error as? CustomNSError else {
                    return completion(nil, error)
                }
                
                if errorResult.errorCode != 401 {
                    completion(nil, error)
                }

                APIClient.refreshToken { (result, error) in
                    if result {
                        APIService.performRequest(from: url, responseType: model) { (response) in
                            switch response {
                            case .success(let value):
                                return completion(value, nil)
                            case .failure(let error):
                                return completion(nil, error)
                            }
                        }
                    } else {
                        Constant.Auth.accessToken = nil
                        Constant.Auth.authorizationToken = nil
                        Constant.Auth.refreshToken = nil

                        completion(nil, error)
                    }
                }
            }
        }
        
        return task
    }
}
