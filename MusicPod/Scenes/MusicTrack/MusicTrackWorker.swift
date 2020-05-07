//
//  MusicTrackWorker.swift
//  MusicPod
//
//  Created by Anderson Rodrigues on 15/04/2020.
//  Copyright (c) 2020 Anderson Soares Rodrigues. All rights reserved.
//

import UIKit

class MusicTrackWorker {
    
    private lazy var playlistWorker = { () -> PlaylistCoreDataWorker in
        return MusicTrackModel.playlistWorker
    }()
    
    private lazy var albumWorker = { () -> AlbumCoreDataWorker in
        return MusicTrackModel.albumWorker
    }()
    
    private lazy var artistWorker = { () -> ArtistCoreDataWorker in
        return MusicTrackModel.artistWorker
    }()
    
    private lazy var trackWorker = { () -> TrackCoreDataWorker in
        return MusicTrackModel.trackWorker
    }()
    
    func fetchPlaylist(_ id: String, completion: @escaping(MusicTrackModel.PlaylistData.Response) -> Void) {
        playlistWorker.setupFetchedResultsController("id == %@", id: id)
        
        if playlistWorker.count() > 0 {
            let data = playlistWorker.list()
            let response = MusicTrackModel.PlaylistData.Response(playlist: data.first!, error: nil)
            return completion(response)
        } else {
            APIClient.getPlaylist(with: id) { (data, error) in
                guard let data = data else {
                    let response = MusicTrackModel.PlaylistData.Response(playlist: nil, error: "Occured an error: \(error!.localizedDescription)")
                    return completion(response)
                }
                
                let playlist = self.playlistWorker.create(obj: data)
                
                let response = MusicTrackModel.PlaylistData.Response(playlist: playlist, error: nil)
                return completion(response)
            }
        }
    }
    
    func fetchAlbum(_ id: String, completion: @escaping(MusicTrackModel.AlbumData.Response) -> Void) {
        albumWorker.setupFetchedResultsController("id == %@", id: id)
        
        if albumWorker.count() > 0 {
            let data = albumWorker.list()
            let response = MusicTrackModel.AlbumData.Response(album: data.first!, error: nil)
            return completion(response)
        } else {
            APIClient.getAlbum(with: id) { (data, error) in
                guard let data = data else {
                    let response = MusicTrackModel.AlbumData.Response(album: nil, error: "Occured an error: \(error!.localizedDescription)")
                    return completion(response)
                }
                
                let album = self.albumWorker.create(obj: data)
                
                if let tracks = data.tracks {
                    for trackData in tracks.items {
                        self.trackWorker.create(obj: trackData, main: album)
                    }
                }
                
                let response = MusicTrackModel.AlbumData.Response(album: album, error: nil)
                return completion(response)
            }
        }
    }
    
    func fetchArtist(_ id: String, completion: @escaping(MusicTrackModel.ArtistData.Response) -> Void) {
        artistWorker.setupFetchedResultsController("id == %@", id: id)
        
        if artistWorker.count() > 0 {
            let data = artistWorker.list()
            let response = MusicTrackModel.ArtistData.Response(artist: data.first!, error: nil)
            return completion(response)
        } else {
            APIClient.getArtist(with: id) { (data, error) in
                guard let data = data else {
                    let response = MusicTrackModel.ArtistData.Response(artist: nil, error: "Ocurred an error: \(error!.localizedDescription)")
                    return completion(response)
                }
                
                let artist = self.artistWorker.create(obj: data)
                
                let response = MusicTrackModel.ArtistData.Response(artist: artist, error: nil)
                return completion(response)
            }
        }
    }
    
    func fetchTrackOn(playlist: Playlist, completion: @escaping(MusicTrackModel.List.Response) -> Void) {
        trackWorker.setupFetchedResultsController("playlist == %@", id: playlist)
        
        if trackWorker.count() > 0 {
            let data = trackWorker.list()
            let response = MusicTrackModel.List.Response(tracks: data, error: nil)
            completion(response)
        } else {
            APIClient.getPlaylistTracks(with: playlist.id!) { (data, error) in
                guard error == nil else {
                    let response = MusicTrackModel.List.Response(tracks: [], error: "Occured an error: \(error!.localizedDescription)")
                    return completion(response)
                }
                
                for playlistTrack in data {
                    if let track = playlistTrack.track {
                        self.trackWorker.create(obj: track, main: playlist)
                    }
                }
                
                let response = MusicTrackModel.List.Response(tracks: self.trackWorker.list(), error: nil)
                return completion(response)
            }
        }
	}
    
    func fetchTrackOn(album: Album, completion: @escaping(MusicTrackModel.List.Response) -> Void) {
        trackWorker.setupFetchedResultsController("album == %@", id: album)
        
        if trackWorker.count() > 0 {
            let data = trackWorker.list()
            let response = MusicTrackModel.List.Response(tracks: data, error: nil)
            completion(response)
        } else {
            APIClient.getAlbumTracks(with: album.id!) { (data, error) in
                guard error == nil else {
                    let response = MusicTrackModel.List.Response(tracks: [], error: "Occured an error: \(error!.localizedDescription)")
                    return completion(response)
                }
                
                for track in data {
                    self.trackWorker.create(obj: track, main: album)
                }
                
                let response = MusicTrackModel.List.Response(tracks: self.trackWorker.list(), error: nil)
                return completion(response)
            }
        }
    }
    
    func fetchTrackOn(artist: Artist, completion: @escaping(MusicTrackModel.List.Response) -> Void) {
        trackWorker.setupFetchedResultsController("ANY artists.id == %@", id: artist.id!)
        
        if trackWorker.count() > 0 {
            let data = trackWorker.list()
            let response = MusicTrackModel.List.Response(tracks: data, error: nil)
            completion(response)
        } else {
            APIClient.getArtistTopTracks(with: artist.id!) { (data, error) in
                guard error == nil else {
                    let response = MusicTrackModel.List.Response(tracks: [], error: "Occured an error: \(error!.localizedDescription)")
                    return completion(response)
                }
                
                for track in data {
                    self.trackWorker.create(obj: track)
                }
                
                let response = MusicTrackModel.List.Response(tracks: self.trackWorker.list(), error: nil)
                return completion(response)
            }
        }
    }
    
    func fetchCoverImagePlaylist(request: MusicTrackModel.CoverImage.Request, completion: @escaping(MusicTrackModel.CoverImage.Response) -> Void ) {
        let object = playlistWorker.read(at: request.indexPath)
        
        if let image = object.image {
            let entry = Entry(cover: image)
            let response = MusicTrackModel.CoverImage.Response(entry: entry, cell: request.cell)
            return completion(response)
        } else if let url = object.imageUrl {
            APIClient.downloadPosterImage(path: url) { (data, error) in
                if let data = data {
                    object.setValue(data, forKey: "image")
                    self.playlistWorker.update(obj: object)
                    
                    let entry = Entry(cover: data)
                    let response = MusicTrackModel.CoverImage.Response(entry: entry, cell: request.cell)
                    return completion(response)
                } else {
                    let entry = Entry(cover: Data())
                    let response = MusicTrackModel.CoverImage.Response(entry: entry, cell: request.cell)
                    return completion(response)
                }
            }
        }
    }
    
    func fetchCoverImageAlbum(request: MusicTrackModel.CoverImage.Request, completion: @escaping(MusicTrackModel.CoverImage.Response) -> Void ) {
        let object = albumWorker.read(at: request.indexPath)
        
        if let image = object.image {
            let entry = Entry(cover: image)
            let response = MusicTrackModel.CoverImage.Response(entry: entry, cell: request.cell)
            return completion(response)
        } else if let url = object.imageUrl {
            APIClient.downloadPosterImage(path: url) { (data, error) in
                if let data = data {
                    object.setValue(data, forKey: "image")
                    self.albumWorker.update(obj: object)
                    
                    let entry = Entry(cover: data)
                    let response = MusicTrackModel.CoverImage.Response(entry: entry, cell: request.cell)
                    return completion(response)
                } else {
                    let entry = Entry(cover: Data())
                    let response = MusicTrackModel.CoverImage.Response(entry: entry, cell: request.cell)
                    return completion(response)
                }
            }
        }
    }
    
    func fetchCoverImageArtist(request: MusicTrackModel.CoverImage.Request, completion: @escaping(MusicTrackModel.CoverImage.Response) -> Void ) {
        let object = artistWorker.read(at: request.indexPath)
        
        if let image = object.image {
            let entry = Entry(cover: image)
            let response = MusicTrackModel.CoverImage.Response(entry: entry, cell: request.cell)
            return completion(response)
        } else if let url = object.imageUrl {
            APIClient.downloadPosterImage(path: url) { (data, error) in
                if let data = data {
                    object.setValue(data, forKey: "image")
                    self.artistWorker.update(obj: object)
                    
                    let entry = Entry(cover: data)
                    let response = MusicTrackModel.CoverImage.Response(entry: entry, cell: request.cell)
                    return completion(response)
                } else {
                    let entry = Entry(cover: Data())
                    let response = MusicTrackModel.CoverImage.Response(entry: entry, cell: request.cell)
                    return completion(response)
                }
            }
        }
    }
    
    func fetchMusicWith(request: MusicTrackModel.FetchSound.Request, completion: @escaping(MusicTrackModel.FetchSound.Response) -> Void) {
        let track = trackWorker.read(at: request.indexPath)
        
        if let data = track.music {
            let response = MusicTrackModel.FetchSound.Response(music: data, indexPath: request.indexPath, cell: request.cell, error: nil)
            return completion(response)
        } else {
            if let previewURL = track.previewUrl, let url = URL(string: previewURL) {
                APIClient.downloadMusic(path: url) { (data, error) in
                    guard let data = data else {
                        let response = MusicTrackModel.FetchSound.Response(music: nil, indexPath: request.indexPath, cell: request.cell, error: "Occured an error: \(error!.localizedDescription)")
                        return completion(response)
                    }
                    
                    track.setValue(data, forKey: "music")
                    self.trackWorker.update(obj: track)
                    
                    let response = MusicTrackModel.FetchSound.Response(music: data, indexPath: request.indexPath, cell: request.cell, error: nil)
                    return completion(response)
                }
            } else {
                let response = MusicTrackModel.FetchSound.Response(music: nil, indexPath: request.indexPath, cell: request.cell, error: "Occured an error: the url was not found")
                return completion(response)
            }
        }
    }
}
