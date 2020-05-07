//
//  LibraryWorker.swift
//  MusicPod
//
//  Created by Anderson Rodrigues on 13/04/2020.
//  Copyright (c) 2020 Anderson Soares Rodrigues. All rights reserved.
//

import UIKit

class LibraryWorker {
    
    private lazy var albumWorker = { () -> AlbumCoreDataWorker in
        let albumWorker = LibraryModel.albumWorker
        albumWorker.setupFetchedResultsController("session == %@", id: "library")
        
        return albumWorker
    }()
    
    private lazy var playlistWorker = { () -> PlaylistCoreDataWorker in
        let playlistWorker = LibraryModel.playlistWorker
        playlistWorker.setupFetchedResultsController("session == %@", id: "library")
        
        return playlistWorker
    }()
    
    func fetchAlbumList(completion: @escaping(LibraryModel.AlbumList.Response) -> Void ) {
        if albumWorker.count() > 0 {
            let data = albumWorker.list()
            let response = LibraryModel.AlbumList.Response(albums: data, isError: false, message: nil)
            completion(response)
        } else {
            APIClient.getCurrentUserSavedAlbums { (data, error) in
                guard error == nil else {
                    let response = LibraryModel.AlbumList.Response(albums: [], isError: true, message: error!.localizedDescription)
                    completion(response)

                    return
                }
                
                self.albumWorker.erase()
                
                for album in data {
                    let albumModel = self.albumWorker.create(obj: album.album!)
                    albumModel.session = "library"
                    self.albumWorker.update(obj: albumModel)
                }
                
                let response = LibraryModel.AlbumList.Response(albums: self.albumWorker.list(), isError: false, message: nil)
                completion(response)
            }
        }
    }
    
    func fetchPlaylistList(completion: @escaping(LibraryModel.PlaylistList.Response) -> Void ) {
        if playlistWorker.count() > 0 {
            let data = playlistWorker.list()
            let response = LibraryModel.PlaylistList.Response(playlists: data, isError: false, message: nil)
            completion(response)
        } else {
            APIClient.getListCurrentUserPlaylist { (data, error) in
                guard error == nil else {
                    let response = LibraryModel.PlaylistList.Response(playlists: [], isError: true, message: error!.localizedDescription)
                    completion(response)

                    return
                }
                
                self.playlistWorker.erase()
                
                for playlist in data {
                    let playlistModel = self.playlistWorker.create(obj: playlist)
                    playlistModel.session = "library"
                    self.playlistWorker.update(obj: playlistModel)
                }
                
                let response = LibraryModel.PlaylistList.Response(playlists: self.playlistWorker.list(), isError: false, message: nil)
                completion(response)
            }
        }
    }
    
    func fetchRefreshAlbumList(completion: @escaping(LibraryModel.AlbumList.Response) -> Void ) {
        APIClient.getCurrentUserSavedAlbums { (data, error) in
            guard error == nil else {
                let response = LibraryModel.AlbumList.Response(albums: [], isError: true, message: error!.localizedDescription)
                completion(response)

                return
            }
            
            self.albumWorker.erase()
            
            for album in data {
                let albumModel = self.albumWorker.create(obj: album.album!)
                albumModel.session = "library"
                self.albumWorker.update(obj: albumModel)
            }
            
            let response = LibraryModel.AlbumList.Response(albums: self.albumWorker.list(), isError: false, message: nil)
            completion(response)
        }
    }
    
    func fetchRefreshPlaylistList(completion: @escaping(LibraryModel.PlaylistList.Response) -> Void ) {
        APIClient.getListCurrentUserPlaylist { (data, error) in
            guard error == nil else {
                let response = LibraryModel.PlaylistList.Response(playlists: [], isError: true, message: error!.localizedDescription)
                completion(response)

                return
            }
            
            self.playlistWorker.erase()
            
            for playlist in data {
                let playlistModel = self.playlistWorker.create(obj: playlist)
                playlistModel.session = "library"
                self.playlistWorker.update(obj: playlistModel)
            }
            
            let response = LibraryModel.PlaylistList.Response(playlists: self.playlistWorker.list(), isError: false, message: nil)
            completion(response)
        }
    }
    
    func fetchPlaylistCoverImage(request: LibraryModel.CoverImage.Request, completion: @escaping(LibraryModel.CoverImage.Response) -> Void ) {
        let object = playlistWorker.read(at: request.indexPath)
        
        if let image = object.image {
            let entry = Entry(cover: image)
            let response = LibraryModel.CoverImage.Response(entry: entry, cell: request.cell)
            completion(response)
        } else if let url = object.imageUrl {
            APIClient.downloadPosterImage(path: url) { (data, error) in
                if let data = data {
                    object.setValue(data, forKey: "image")
                    self.playlistWorker.update(obj: object)
                    
                    let entry = Entry(cover: data)
                    let response = LibraryModel.CoverImage.Response(entry: entry, cell: request.cell)
                    completion(response)
                }
            }
        }
    }
    
    func fetchAlbumCoverImage(request: LibraryModel.CoverImage.Request, completion: @escaping(LibraryModel.CoverImage.Response) -> Void ) {
        let object = albumWorker.read(at: request.indexPath)
        
        if let image = object.image {
            let entry = Entry(cover: image)
            let response = LibraryModel.CoverImage.Response(entry: entry, cell: request.cell)
            completion(response)
        } else if let url = object.imageUrl {
            APIClient.downloadPosterImage(path: url) { (data, error) in
                if let data = data {
                    object.setValue(data, forKey: "image")
                    self.albumWorker.update(obj: object)
                    
                    let entry = Entry(cover: data)
                    let response = LibraryModel.CoverImage.Response(entry: entry, cell: request.cell)
                    completion(response)
                }
            }
        }
    }
}
