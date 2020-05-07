//
//  CategoryPlaylistWorker.swift
//  MusicPod
//
//  Created by Anderson Rodrigues on 13/04/2020.
//  Copyright (c) 2020 Anderson Soares Rodrigues. All rights reserved.
//

import UIKit

class CategoryPlaylistWorker {
    
    private lazy var playlistWorker = { () -> PlaylistCoreDataWorker in
        return CategoryPlaylistModel.playlistWorker
    }()
    
    func fetchCategoryPlaylistList(_ category: Category, completion: @escaping(CategoryPlaylistModel.List.Response) -> Void ) {
        playlistWorker.setupFetchedResultsController("category == %@", id: category)
        
        if playlistWorker.count() > 0 {
            let data = playlistWorker.list()
            let response = CategoryPlaylistModel.List.Response(playlists: data, isError: false, message: nil)
            completion(response)
        } else {
            APIClient.getCategoryPlaylists(on: category.id!) { (data, error) in
                guard error == nil else {
                    let response = CategoryPlaylistModel.List.Response(playlists: [], isError: true, message: error!.localizedDescription)
                    completion(response)

                    return
                }
                
                for playlist in data {
                    let playlistModel = self.playlistWorker.create(obj: playlist)
                    playlistModel.category = category
                    self.playlistWorker.update(obj: playlistModel)
                }
                
                let response = CategoryPlaylistModel.List.Response(playlists: self.playlistWorker.list(), isError: false, message: nil)
                completion(response)
            }
        }
    }
    
    func fetchRefreshCategoryPlaylistList(_ category: Category, completion: @escaping(CategoryPlaylistModel.List.Response) -> Void ) {
        APIClient.getCategoryPlaylists(on: category.id!) { (data, error) in
            guard error == nil else {
                let response = CategoryPlaylistModel.List.Response(playlists: [], isError: true, message: error!.localizedDescription)
                completion(response)

                return
            }
            
            self.playlistWorker.erase()
            
            for playlist in data {
                let playlistModel = self.playlistWorker.create(obj: playlist)
                playlistModel.category = category
                self.playlistWorker.update(obj: playlistModel)
            }
            
            let response = CategoryPlaylistModel.List.Response(playlists: self.playlistWorker.list(), isError: false, message: nil)
            completion(response)
        }
    }
    
    func fetchCategoryPlaylistCoverImage(request: CategoryPlaylistModel.CoverImage.Request, completion: @escaping(CategoryPlaylistModel.CoverImage.Response) -> Void ) {
        let object = playlistWorker.read(at: request.indexPath)
        
        if let image = object.image {
            let entry = Entry(cover: image)
            let response = CategoryPlaylistModel.CoverImage.Response(entry: entry, cell: request.cell)
            completion(response)
        } else if let url = object.imageUrl {
            APIClient.downloadPosterImage(path: url) { (data, error) in
                if let data = data {
                    object.setValue(data, forKey: "image")
                    self.playlistWorker.update(obj: object)
                    
                    let entry = Entry(cover: data)
                    let response = CategoryPlaylistModel.CoverImage.Response(entry: entry, cell: request.cell)
                    completion(response)
                }
            }
        }
    }
}
