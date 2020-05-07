//
//  HomeWorker.swift
//  MusicPod
//
//  Created by Anderson Soares Rodrigues on 26/03/20.
//  Copyright (c) 2020 Anderson Soares Rodrigues. All rights reserved.
//

import UIKit

class HomeWorker {
    
    private lazy var albumWorker = { () -> AlbumCoreDataWorker in
        let albumWorker = HomeModel.albumWorker
        albumWorker.setupFetchedResultsController("session == %@", id: "home")
        
        return albumWorker
    }()
    
    private lazy var artistWorker = { () -> ArtistCoreDataWorker in
        let artistWorker = HomeModel.artistWorker
        artistWorker.setupFetchedResultsController("session == %@", id: "home")
        
        return artistWorker
    }()
    
    private lazy var playlistWorker = { () -> PlaylistCoreDataWorker in
        let playlistWorker = HomeModel.playlistWorker
        playlistWorker.setupFetchedResultsController("session == %@", id: "home")
        
        return playlistWorker
    }()
    
    func fetchTopArtistsAndTracks(completion: @escaping(HomeModel.TopArtists.Response) -> Void ) {
        if artistWorker.count() > 0 {
            let data = artistWorker.list()
            let response = HomeModel.TopArtists.Response(artists: data, isError: false, message: nil)
            completion(response)
        } else {
            APIClient.getUserTopArtistsAndTracks(as: "artists") { (data, error) in
                guard error == nil else {
                    let response = HomeModel.TopArtists.Response(artists: [], isError: true, message: error!.localizedDescription)
                    completion(response)

                    return
                }
                
                for artist in data {
                    let artistModel = self.artistWorker.create(obj: artist)
                    artistModel.session = "home"
                    self.artistWorker.update(obj: artistModel)
                }
                
                let response = HomeModel.TopArtists.Response(artists: self.artistWorker.list(), isError: false, message: nil)
                completion(response)
            }
        }
    }
    
    func fetchNewRelease(completion: @escaping(HomeModel.NewRelease.Response) -> Void ) {
        if albumWorker.count() > 0 {
            let data = albumWorker.list()
            let response = HomeModel.NewRelease.Response(albums: data, isError: false, message: nil)
            completion(response)
        } else {
            APIClient.getListNewReleases { (data, error) in
                guard error == nil else {
                    let response = HomeModel.NewRelease.Response(albums: [], isError: true, message: error!.localizedDescription)
                    completion(response)

                    return
                }
                
                for album in data {
                    let albumModel = self.albumWorker.create(obj: album)
                    albumModel.session = "home"
                    self.albumWorker.update(obj: albumModel)
                }
                
                let response = HomeModel.NewRelease.Response(albums: self.albumWorker.list(), isError: false, message: nil)
                completion(response)
            }
        }
    }
    
    func fetchFeaturePlaylists(completion: @escaping(HomeModel.FeaturePlaylists.Response) -> Void ) {
        if playlistWorker.count() > 0 {
            let data = playlistWorker.list()
            let response = HomeModel.FeaturePlaylists.Response(playlists: data, isError: false, message: nil)
            completion(response)
        } else {
            APIClient.getListFeaturedPlaylist { (data, error) in
                guard error == nil else {
                    let response = HomeModel.FeaturePlaylists.Response(playlists: [], isError: true, message: error!.localizedDescription)
                    completion(response)

                    return
                }
                
                for playlist in data {
                    let playlistModel = self.playlistWorker.create(obj: playlist)
                    playlistModel.session = "home"
                    self.playlistWorker.update(obj: playlistModel)
                }
                
                let response = HomeModel.FeaturePlaylists.Response(playlists: self.playlistWorker.list(), isError: false, message: nil)
                completion(response)
            }
        }
    }
    
    func fetchPlaylistCoverImage(request: HomeModel.CoverImage.Request, completion: @escaping(HomeModel.CoverImage.Response) -> Void ) {
        let object = playlistWorker.read(at: request.indexPath)
        
        if let image = object.image {
            let entry = Entry(cover: image)
            let response = HomeModel.CoverImage.Response(entry: entry, cell: request.cell)
            completion(response)
        } else if let url = object.imageUrl {
            APIClient.downloadPosterImage(path: url) { (data, error) in
                if let data = data {
                    object.setValue(data, forKey: "image")
                    self.playlistWorker.update(obj: object)
                    
                    let entry = Entry(cover: data)
                    let response = HomeModel.CoverImage.Response(entry: entry, cell: request.cell)
                    completion(response)
                }
            }
        }
    }
    
    func fetchAlbumCoverImage(request: HomeModel.CoverImage.Request, completion: @escaping(HomeModel.CoverImage.Response) -> Void ) {
        let object = albumWorker.read(at: request.indexPath)
        
        if let image = object.image {
            let entry = Entry(cover: image)
            let response = HomeModel.CoverImage.Response(entry: entry, cell: request.cell)
            completion(response)
        } else if let url = object.imageUrl {
            APIClient.downloadPosterImage(path: url) { (data, error) in
                if let data = data {
                    object.setValue(data, forKey: "image")
                    self.albumWorker.update(obj: object)
                    
                    let entry = Entry(cover: data)
                    let response = HomeModel.CoverImage.Response(entry: entry, cell: request.cell)
                    completion(response)
                }
            }
        }
    }
    
    func fetchArtistCoverImage(request: HomeModel.CoverImage.Request, completion: @escaping(HomeModel.CoverImage.Response) -> Void ) {
        let object = artistWorker.read(at: request.indexPath)
        
        if let image = object.image {
            let entry = Entry(cover: image)
            let response = HomeModel.CoverImage.Response(entry: entry, cell: request.cell)
            completion(response)
        } else if let url = object.imageUrl {
            APIClient.downloadPosterImage(path: url) { (data, error) in
                if let data = data {
                    object.setValue(data, forKey: "image")
                    self.artistWorker.update(obj: object)
                    
                    let entry = Entry(cover: data)
                    let response = HomeModel.CoverImage.Response(entry: entry, cell: request.cell)
                    completion(response)
                }
            }
        }
    }
}
