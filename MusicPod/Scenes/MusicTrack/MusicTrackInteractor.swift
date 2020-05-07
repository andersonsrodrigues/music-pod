//
//  MusicTrackInteractor.swift
//  MusicPod
//
//  Created by Anderson Rodrigues on 15/04/2020.
//  Copyright (c) 2020 Anderson Soares Rodrigues. All rights reserved.
//

import UIKit
import AVFoundation

// MARK: - Protocol
protocol MusicTrackBusinessLogic {
    // MARK: Request Methods
	func requestTrackList(request: MusicTrackModel.List.Request)
    func requestCoverImage(request: MusicTrackModel.CoverImage.Request)

    // MARK: CRUD operations
    func fetchTrackRow(request: MusicTrackModel.FetchListAndConfigureCell.Request)
    func fetchMusicDetailRow(request: MusicTrackModel.FetchMusicDescAndConfigureCell.Request)
    
    // MARK: Search
    
    // MARK: Music
    func checkTrackToPlayMusic(request: MusicTrackModel.Music.Request) -> Bool
    
    // MARK: Count
    func count() -> Int
    
    // MARK: Track update lifecycle
    func startTrackUpdates(request: MusicTrackModel.StartTrackUpdates.Request)
    func stopTrackUpdates(request: MusicTrackModel.StopTrackUpdates.Request)
    
    // MARK: Player
    func requestActionOnMusic(request: MusicTrackModel.FetchSound.Request)
}

protocol MusicTrackDataStore {
	var playlist: Playlist? { get set }
    var album: Album? { get set }
    var artist: Artist? { get set }
    var searchResult: Search? { get set }
}

class MusicTrackInteractor: NSObject, MusicTrackBusinessLogic, MusicTrackDataStore {
    
    var playlist: Playlist?
    var album: Album?
    var artist: Artist?
    var searchResult: Search?
    
	var presenter: MusicTrackPresentationLogic?
	var worker: MusicTrackWorker?
    
    var trackWorker = MusicTrackModel.trackWorker
    var playlistWorker = MusicTrackModel.playlistWorker
    
    var audioPlayer: AVAudioPlayer?
    var currentPlaying: TrackTableViewCell?
    var statusMusic: MusicTrackModel.PlayingState = .notPlaying
	
	// MARK: Request Methods
	
	func requestTrackList(request: MusicTrackModel.List.Request) {
		worker = MusicTrackWorker()
        
        if let worker = worker {
            if let search = searchResult {
                checkSearch(result: search)
            } else {
                if let playlist = playlist {
                    worker.fetchTrackOn(playlist: playlist) { response in
                        self.presenter?.presentTrackList(response: response)
                    }
                } else if let album = album {
                    worker.fetchTrackOn(album: album) { response in
                        self.presenter?.presentTrackList(response: response)
                    }
                } else if let artist = artist {
                    worker.fetchTrackOn(artist: artist) { response in
                        self.presenter?.presentTrackList(response: response)
                    }
                }
            }
        }
	}
    
    func requestPlaylist(request: MusicTrackModel.PlaylistData.Request) {
        worker = MusicTrackWorker()
        
        if let worker = worker {
            worker.fetchPlaylist(request.id) { response in
                
                if let playlist = response.playlist {
                    self.playlist = playlist
                    self.presenter?.presentPlaylist(response: response)
                } else {
                    fatalError("Error Fetch Playlist")
                }
            }
        }
    }
    
    func requestAlbum(request: MusicTrackModel.AlbumData.Request) {
        worker = MusicTrackWorker()
        
        if let worker = worker {
            worker.fetchAlbum(request.id) { response in
                
                if let album = response.album {
                    self.album = album
                    self.presenter?.presentAlbum(response: response)
                } else {
                    fatalError("Error Fetch Album")
                }
            }
        }
    }
    
    func requestArtist(request: MusicTrackModel.ArtistData.Request) {
        worker = MusicTrackWorker()
        
        if let worker = worker {
            worker.fetchArtist(request.id) { response in
                
                if let artist = response.artist {
                    self.artist = artist
                    
                    worker.fetchTrackOn(artist: artist) { response in
                        self.presenter?.presentTrackList(response: response)
                    }
                } else {
                    fatalError("Error Fetch Artist")
                }
            }
        }
    }
    
    func requestCoverImage(request: MusicTrackModel.CoverImage.Request) {
        worker = MusicTrackWorker()
        
        if let worker = worker {
            if let _ = playlist {
                worker.fetchCoverImagePlaylist(request: request) { response in
                    self.presenter?.presentCoverImage(response: response)
                }
            } else if let _ = album {
                worker.fetchCoverImageAlbum(request: request) { response in
                    self.presenter?.presentCoverImage(response: response)
                }
            } else if let _ = artist {
                worker.fetchCoverImageArtist(request: request) { response in
                    self.presenter?.presentCoverImage(response: response)
                }
            } else {
                worker.fetchCoverImagePlaylist(request: request) { response in
                    self.presenter?.presentCoverImage(response: response)
                }
            }
        }
    }
    
    // MARK: CRUD operations
    
    func fetchTrackRow(request: MusicTrackModel.FetchListAndConfigureCell.Request) {
        let track = trackWorker.read(at: request.indexPath)
        
        let response = MusicTrackModel.FetchListAndConfigureCell.Response(track: track, cell: request.cell, indexPath: request.indexPath)
        presenter?.presentFetchedTrackRowAndConfigureCell(response: response)
    }
    
    func fetchMusicDetailRow(request: MusicTrackModel.FetchMusicDescAndConfigureCell.Request) {
        let response = MusicTrackModel.FetchMusicDescAndConfigureCell.Response(playlist: playlist, album: album, artist: artist, cell: request.cell, indexPath: request.indexPath)
        presenter?.presentFetchedMusicDescRowAndConfigureCell(response: response)
    }
    
    // MARK: Search
    
    private func checkSearch(result: Search) {
        switch result.type {
        case "album":
            let request = MusicTrackModel.AlbumData.Request(id: result.id)
            requestAlbum(request: request)
        case "artist":
            let request = MusicTrackModel.ArtistData.Request(id: result.id)
            requestArtist(request: request)
        case "playlist":
            let request = MusicTrackModel.PlaylistData.Request(id: result.id)
            requestPlaylist(request: request)
        default:
            break
        }
    }
    
    // MARK: Music
    
    func checkTrackToPlayMusic(request: MusicTrackModel.Music.Request) -> Bool {
        let track = trackWorker.read(at: request.indexPath)
        
        if let _ = track.previewUrl {
            return true
        } else {
            return false
        }
    }
    
    // MARK: Count
    
    func count() -> Int {
        if let playlist = playlist {
            trackWorker.setupFetchedResultsController("playlist == %@", id: playlist)
            return trackWorker.count()
        } else if let album = album {
            trackWorker.setupFetchedResultsController("album == %@", id: album)
            return trackWorker.count()
        } else if let artist = artist {
            trackWorker.setupFetchedResultsController("ANY artists.id == %@", id: artist.id!)
            return trackWorker.count()
        }
        
        return 0
    }
    
    // MARK: Sound
    
    private func downloadSound(request: MusicTrackModel.FetchSound.Request) {
        let track = trackWorker.read(at: request.indexPath)
        
        if let _ = track.previewUrl {
            worker = MusicTrackWorker()

            if let worker = worker {
                worker.fetchMusicWith(request: request) { response in
                    
                    if let data = response.music {
                        self.initAudio(data: data)
                    }
                    
                    self.presenter?.presentMusicDownload(response: response)
                }
            }
        } else {
            let response = MusicTrackModel.FetchSound.Response(music: nil, indexPath: request.indexPath, cell: request.cell, error: "Error to play \(track.name!), try again later")
            self.presenter?.presentMusicDownload(response: response)
        }
    }
    
    func requestActionOnMusic(request: MusicTrackModel.FetchSound.Request) {
        if let _ = audioPlayer {
            
            if statusMusic == .notPlaying {
                playSound(on: request.cell)
            } else {
                if let cell = currentPlaying {
                    if cell.tag != request.cell.tag {
                        stopSound(on: cell)
                        downloadSound(request: request)
                    } else {
                        stopSound(on: request.cell)
                    }
                }
            }
        } else {
            downloadSound(request: request)
        }
    }
}

// MARK: - NSFetchedResultsController

extension MusicTrackInteractor: TrackCoreDataWorkerDelegate {
    
    // MARK: Track update lifecycle
    
    func startTrackUpdates(request: MusicTrackModel.StartTrackUpdates.Request) {
        trackWorker.delegates.append(self)
    }
    
    func stopTrackUpdates(request: MusicTrackModel.StopTrackUpdates.Request) {
        if let index = trackWorker.delegates.firstIndex(where: { $0 === self }) {
            trackWorker.delegates.remove(at: index)
        }
    }
    
    // MARK: Album row updates
    
    func trackCoreDataWorker(trackCoreDataWorker: TrackCoreDataWorker, shouldInsertRowAt indexPath: IndexPath) {
        presenter?.presentInsertedRow(at: indexPath)
    }
    
    func trackCoreDataWorker(trackCoreDataWorker: TrackCoreDataWorker, shouldDeleteRowAt indexPath: IndexPath) {
        presenter?.presentDeletedRow(at: indexPath)
    }
    
    func trackCoreDataWorker(trackCoreDataWorker: TrackCoreDataWorker, shouldUpdateRowAt indexPath: IndexPath, withTrack track: Track) {
        presenter?.presentUpdatedRow(at: indexPath, withTrack: track)
    }
    
    func trackCoreDataWorker(trackCoreDataWorker: TrackCoreDataWorker, shouldMoveRowFrom from: IndexPath, to: IndexPath, withTrack track: Track) {
        presenter?.presentMovedRow(from: from, to: to, withTrack: track)
    }
}

// MARK: - AVAudioPlayerDelegate

extension MusicTrackInteractor: AVAudioPlayerDelegate {
    func initAudio(data: Data) {
        do {
            audioPlayer = try AVAudioPlayer(data: data)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func playSound(on cell: TrackTableViewCell) {
        if let player = audioPlayer {
            player.play()
            currentPlaying = cell
            configureUI(.playing)
            
            let response = MusicTrackModel.FetchSound.Response(music: nil, indexPath: nil, cell: cell, error: nil)
            presenter?.presentMusicPlaying(response: response)
        }
    }
    
    func stopSound(on cell: TrackTableViewCell) {
        if let player = audioPlayer {
            player.pause()
            audioPlayer = nil
            currentPlaying = nil
            configureUI(.notPlaying)
            
            let response = MusicTrackModel.FetchSound.Response(music: nil, indexPath: nil, cell: cell, error: nil)
            presenter?.presentMusicStop(response: response)
        }
    }
    
    // MARK: UI Functions

    private func configureUI(_ playState: MusicTrackModel.PlayingState) {
        switch(playState) {
        case .playing:
            statusMusic = .playing
        case .notPlaying:
            statusMusic = .notPlaying
        }
    }
}
