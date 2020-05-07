//
//  MusicTrackPresenter.swift
//  MusicPod
//
//  Created by Anderson Rodrigues on 15/04/2020.
//  Copyright (c) 2020 Anderson Soares Rodrigues. All rights reserved.
//

import UIKit

// MARK: - Protocol
protocol MusicTrackPresentationLogic {
    // MARK: Present Methods
	func presentTrackList(response: MusicTrackModel.List.Response)
    func presentPlaylist(response: MusicTrackModel.PlaylistData.Response)
    func presentAlbum(response: MusicTrackModel.AlbumData.Response)
    func presentArtist(response: MusicTrackModel.ArtistData.Response)
    func presentCoverImage(response: MusicTrackModel.CoverImage.Response)
    
    // MARK: CRUD operations
    func presentFetchedTrackRowAndConfigureCell(response: MusicTrackModel.FetchListAndConfigureCell.Response)
    func presentFetchedMusicDescRowAndConfigureCell(response: MusicTrackModel.FetchMusicDescAndConfigureCell.Response)
    
    // MARK: Track row lifecycle
    func presentInsertedRow(at indexPath: IndexPath)
    func presentDeletedRow(at indexPath: IndexPath)
    func presentUpdatedRow(at indexPath: IndexPath, withTrack displayTrack: Track)
    func presentMovedRow(from: IndexPath, to: IndexPath, withTrack displayTrack: Track)
    
    // MARK: Music
    func presentMusicDownload(response: MusicTrackModel.FetchSound.Response)
    func presentMusicPlaying(response: MusicTrackModel.FetchSound.Response)
    func presentMusicStop(response: MusicTrackModel.FetchSound.Response)
}

class MusicTrackPresenter: MusicTrackPresentationLogic {
	weak var viewController: MusicTrackDisplayLogic?
	
	// MARK: Do something
	
	func presentTrackList(response: MusicTrackModel.List.Response) {
        let viewModel = MusicTrackModel.List.ViewModel(tracks: response.tracks, error: response.error)
        
        if let _ = response.error {
            viewController?.displayErrorTrackList(viewModel: viewModel)
        } else {
            viewController?.displayTrackList(viewModel: viewModel)
        }
	}
    
    func presentPlaylist(response: MusicTrackModel.PlaylistData.Response) {
        let viewModel = MusicTrackModel.PlaylistData.ViewModel(playlist: response.playlist, error: response.error)
        
        if let _ = response.error {
            viewController?.displayErrorPlaylist(viewModel: viewModel)
        } else {
            viewController?.displayPlaylist(viewModel: viewModel)
        }
    }
    
    func presentAlbum(response: MusicTrackModel.AlbumData.Response) {
        let viewModel = MusicTrackModel.AlbumData.ViewModel(album: response.album, error: response.error)
        
        if let _ = response.error {
            viewController?.displayErrorAlbum(viewModel: viewModel)
        } else {
            viewController?.displayAlbum(viewModel: viewModel)
        }
    }
    
    func presentArtist(response: MusicTrackModel.ArtistData.Response) {
        let viewModel = MusicTrackModel.ArtistData.ViewModel(artist: response.artist, error: response.error)
        
        if let _ = response.error {
            viewController?.displayErrorArtist(viewModel: viewModel)
        } else {
            viewController?.displayArtist(viewModel: viewModel)
        }
    }
    
    func presentCoverImage(response: MusicTrackModel.CoverImage.Response) {
        let displayedImage = convert(data: response.entry.cover)
        
        let viewModel = MusicTrackModel.CoverImage.ViewModel(displayedEntry: displayedImage, cell: response.cell)
        viewController?.displayCoverImage(viewModel: viewModel)
    }
    
    // MARK: CRUD operations
    
    func presentFetchedTrackRowAndConfigureCell(response: MusicTrackModel.FetchListAndConfigureCell.Response) {
        let displayedTrack = formatTrackCell(track: response.track)
        
        let viewModel = MusicTrackModel.FetchListAndConfigureCell.ViewModel(displayedTrack: displayedTrack, cell: response.cell, indexPath: response.indexPath)
        viewController?.displayFetchedTrackRowAndConfigureCell(viewModel: viewModel)
    }
    
    func presentFetchedMusicDescRowAndConfigureCell(response: MusicTrackModel.FetchMusicDescAndConfigureCell.Response) {
        var displayedMusicDesc = MusicTrackModel.DisplayedDescCell()
        
        if let playlist = response.playlist {
            displayedMusicDesc = formatMusicDescCell(playlist: playlist)
        } else if let album = response.album {
            displayedMusicDesc = formatMusicDescCell(album: album)
        } else if let artist = response.artist {
            displayedMusicDesc = formatMusicDescCell(artist: artist)
        }
        
        let viewModel = MusicTrackModel.FetchMusicDescAndConfigureCell.ViewModel(displayedMusicDesc: displayedMusicDesc, cell: response.cell, indexPath: response.indexPath)
        viewController?.displayFetchedMusicDescRowAndConfigureCell(viewModel: viewModel)
    }
    
    // MARK: - Format Character Cell
    
    private func formatTrackCell(track: Track) -> MusicTrackModel.DisplayedTrackCell {
        return MusicTrackModel.DisplayedTrackCell(name: track.name!, artistName: track.getAllArtists())
    }
    
    private func formatMusicDescCell(playlist: Playlist) -> MusicTrackModel.DisplayedDescCell {
        return MusicTrackModel.DisplayedDescCell(name: playlist.name, desc: playlist.desc, image: playlist.image, url: playlist.imageUrl)
    }
    
    private func formatMusicDescCell(album: Album) -> MusicTrackModel.DisplayedDescCell {
        return MusicTrackModel.DisplayedDescCell(name: album.name, desc: nil, image: album.image, url: album.imageUrl)
    }
    
    private func formatMusicDescCell(artist: Artist) -> MusicTrackModel.DisplayedDescCell {
        return MusicTrackModel.DisplayedDescCell(name: artist.name, desc: nil, image: artist.image, url: artist.imageUrl)
    }
    
    // MARK: - Format data to displayed entry
    
    private func convert(data: Data) -> MusicTrackModel.DisplayedImage? {
        if let image = UIImage(data: data) {
            return MusicTrackModel.DisplayedImage(cover: image)
        } else {
            return nil
        }
    }
    
    // MARK: - Music
    
    func presentMusicDownload(response: MusicTrackModel.FetchSound.Response) {
        let viewModel = MusicTrackModel.FetchSound.ViewModel(indexPath: response.indexPath, cell: response.cell, error: response.error)
        
        if let _ = response.error {
            viewController?.displayErrorMusicDownload(viewModel: viewModel)
        } else {
            viewController?.displayMusicDownloaded(viewModel: viewModel)
        }
    }
    
    func presentMusicPlaying(response: MusicTrackModel.FetchSound.Response) {
        let viewModel = MusicTrackModel.FetchSound.ViewModel(indexPath: response.indexPath, cell: response.cell, error: response.error)
        
        if let _ = response.error {
            viewController?.displayErrorMusicDownload(viewModel: viewModel)
        } else {
            viewController?.displayMusicPlaying(viewModel: viewModel)
        }
    }
    
    func presentMusicStop(response: MusicTrackModel.FetchSound.Response) {
        let viewModel = MusicTrackModel.FetchSound.ViewModel(indexPath: response.indexPath, cell: response.cell, error: response.error)
        
        if let _ = response.error {
            viewController?.displayErrorMusicDownload(viewModel: viewModel)
        } else {
            viewController?.displayMusicStopping(viewModel: viewModel)
        }
    }
}

// MARK: - NSFetchedResultsController
extension MusicTrackPresenter {
    // MARK: Track row updates
    
    func presentInsertedRow(at indexPath: IndexPath) {
        viewController?.displayInsertedRow(at: indexPath)
    }
    
    func presentDeletedRow(at indexPath: IndexPath) {
        viewController?.displayDeletedRow(at: indexPath)
    }
    
    func presentUpdatedRow(at indexPath: IndexPath, withTrack displayTrack: Track) {
        let displayedTrack = formatTrackCell(track: displayTrack)
        viewController?.displayUpdatedRow(at: indexPath, withDisplayedTrack: displayedTrack)
    }
    
    func presentMovedRow(from: IndexPath, to: IndexPath, withTrack displayTrack: Track) {
        let displayedTrack = formatTrackCell(track: displayTrack)
        viewController?.displayMovedRow(from: from, to: to, withDisplayedTrack: displayedTrack)
    }
}
