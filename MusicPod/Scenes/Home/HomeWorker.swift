//
//  HomeWorker.swift
//  MusicPod
//
//  Created by Anderson Soares Rodrigues on 26/03/20.
//  Copyright (c) 2020 Anderson Soares Rodrigues. All rights reserved.
//

import UIKit

class HomeWorker {
    func getUserTopArtistsAndTracks(as type: String, completion: @escaping([Artist], Error?) -> Void) {
        APIClient.performRequest(router: APIRouter.getUserTopArtistsAndTracks(type), responseType: Paging<Artist>.self) { response in
            switch response {
            case .success(let value):
                return completion(value.items, nil)
            case .failure(let error):
                return completion([], error)
            }
        }
    }
    
    func getListNewReleases(completion: @escaping([Album], Error?) -> Void) {
        APIClient.performRequest(router: APIRouter.getListNewReleases, responseType: AlbumsResponse<Album>.self) { response in
            switch response {
            case .success(let value):
                return completion(value.albums.items, nil)
            case .failure(let error):
                return completion([], error)
            }
        }
    }
    
    func getListFeaturedPlaylist(completion: @escaping([PlaylistSimplified], Error?) -> Void) {
        APIClient.performRequest(router: APIRouter.getFeaturedPlaylists, responseType: PlaylistsResponse<PlaylistSimplified>.self) { response in
            switch response {
            case .success(let value):
                return completion(value.playlists.items, nil)
            case .failure(let error):
                return completion([], error)
            }
        }
    }
    
    func downloadPosterImage(path: String, completion: @escaping (Data?, Error?) -> Void) {
        APIClient.perfomDownload()
//        let task = URLSession.shared.dataTask(with: APIRouter.posterImage(path)) { data, response, error in
//            DispatchQueue.main.async {
//                completion(data, error)
//            }
//        }
//        task.resume()
    }
}
