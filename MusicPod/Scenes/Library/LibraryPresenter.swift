//
//  LibraryPresenter.swift
//  MusicPod
//
//  Created by Anderson Rodrigues on 13/04/2020.
//  Copyright (c) 2020 Anderson Soares Rodrigues. All rights reserved.
//

import UIKit

// MARK: - Protocol
protocol LibraryPresentationLogic {
    // MARK: Fetch Handle
    func presentPlaylistList(response: LibraryModel.PlaylistList.Response)
    func presentAlbumList(response: LibraryModel.AlbumList.Response)
    func presentCoverImage(response: LibraryModel.CoverImage.Response)
    
    // MARK: CRUD operations
    func presentFetchedPlaylistListAndConfigureCell(response: LibraryModel.FetchPlaylistAndConfigureCell.Response)
    func presentFetchedAlbumListAndConfigureCell(response: LibraryModel.FetchAlbumAndConfigureCell.Response)
    
    // MARK: Library update lifecycle
    func presentStartLibraryUpdates(response: LibraryModel.StartLibraryUpdates.Response)
    func presentStopLibraryUpdates(response: LibraryModel.StopLibraryUpdates.Response)
    func presentInsertedRow(at indexPath: IndexPath)
    func presentDeletedRow(at indexPath: IndexPath)
    func presentUpdatedRow(at indexPath: IndexPath, withAlbum album: Album?, withPlaylist playlist: Playlist?)
    func presentMovedRow(from: IndexPath, to: IndexPath, withAlbum album: Album?, withPlaylist playlist: Playlist?)
}

class LibraryPresenter: LibraryPresentationLogic {
    
    weak var viewController: LibraryDisplayLogic?
    
    // MARK: Fetch Handle
    
    func presentPlaylistList(response: LibraryModel.PlaylistList.Response) {
        let viewModel = LibraryModel.PlaylistList.ViewModel(playlists: response.playlists, isError: response.isError, message: response.message)
        
        if response.isError {
            viewController?.displayErrorPlaylistList(viewModel: viewModel)
        } else {
            viewController?.displayPlaylistList(viewModel: viewModel)
        }
    }
    
    func presentAlbumList(response: LibraryModel.AlbumList.Response) {
        let viewModel = LibraryModel.AlbumList.ViewModel(albums: response.albums, isError: response.isError, message: response.message)
        
        if response.isError {
            viewController?.displayErrorAlbumList(viewModel: viewModel)
        } else {
            viewController?.displayAlbumList(viewModel: viewModel)
        }
    }
    
    func presentCoverImage(response: LibraryModel.CoverImage.Response) {
        let displayEntry = convert(entry: response.entry)
        let viewModel = LibraryModel.CoverImage.ViewModel(displayedEntry: displayEntry, cell: response.cell)
        viewController?.displayCoverImage(viewModel: viewModel)
    }
    
    // MARK: CRUD operations
    
    func presentFetchedAlbumListAndConfigureCell(response: LibraryModel.FetchAlbumAndConfigureCell.Response) {
        let displayedAlbum = formatCell(album: response.album, playlist: nil)
        
        let viewModel = LibraryModel.FetchAlbumAndConfigureCell.ViewModel(displayedAlbum: displayedAlbum!, indexPath: response.indexPath, cell: response.cell)
        viewController?.displayFetchedAlbumAndConfigureCell(viewModel: viewModel)
    }
    
    func presentFetchedPlaylistListAndConfigureCell(response: LibraryModel.FetchPlaylistAndConfigureCell.Response) {
        let displayedPlaylist = formatCell(album: nil, playlist: response.playlist)
        
        let viewModel = LibraryModel.FetchPlaylistAndConfigureCell.ViewModel(displayedPlaylist: displayedPlaylist!, indexPath: response.indexPath, cell: response.cell)
        viewController?.displayFetchedPlaylistAndConfigureCell(viewModel: viewModel)
    }
    
    // MARK: Format entry to displayed entry
    
    private func convert(entry: Entry) -> LibraryModel.DisplayedEntry {
        let image = UIImage(data: entry.cover)
        return LibraryModel.DisplayedEntry(cover: image!)
    }
    
    // MARK: - Format Album & Playlist
    
    func formatCell(album: Album?, playlist: Playlist?) -> LibraryModel.DisplayedCell? {
        if let data = album {
            return LibraryModel.DisplayedCell(name: data.name!, desc: data.getAllArtists(),image: data.image, url: data.imageUrl)
        } else if let data = playlist {
            return LibraryModel.DisplayedCell(name: data.name!, desc: data.desc!, image: data.image, url: data.imageUrl)
        }
        
        return nil
    }
}

// MARK: - NSFetchedResultsController

extension LibraryPresenter {
    // MARK: Library update lifecycle
    
    func presentStartLibraryUpdates(response: LibraryModel.StartLibraryUpdates.Response) {
        let viewModel = LibraryModel.StartLibraryUpdates.ViewModel()
        viewController?.displayStartLibraryUpdates(viewModel: viewModel)
    }
    
    func presentStopLibraryUpdates(response: LibraryModel.StopLibraryUpdates.Response) {
        let viewModel = LibraryModel.StopLibraryUpdates.ViewModel()
        viewController?.displayStopLibraryUpdates(viewModel: viewModel)
    }
    
    // MARK: Library row updates
    
    func presentInsertedRow(at indexPath: IndexPath) {
        viewController?.displayInsertedRow(at: indexPath)
    }
    
    func presentDeletedRow(at indexPath: IndexPath) {
        viewController?.displayDeletedRow(at: indexPath)
    }
    
    func presentUpdatedRow(at indexPath: IndexPath, withAlbum album: Album?, withPlaylist playlist: Playlist?) {
        let displayedLibrary = formatCell(album: album, playlist: playlist)
        
        if let _ = album {
            viewController?.displayUpdatedRow(at: indexPath, as: .album, withDisplayedLibrary: displayedLibrary!)
        } else if let _ = playlist {
            viewController?.displayUpdatedRow(at: indexPath, as: .playlist, withDisplayedLibrary: displayedLibrary!)
        }
    }
    
    func presentMovedRow(from: IndexPath, to: IndexPath, withAlbum album: Album?, withPlaylist playlist: Playlist?) {
        let displayedLibrary = formatCell(album: album, playlist: playlist)
        
        if let _ = album {
            viewController?.displayMovedRow(from: from, to: to, as: .album, withDisplayedLibrary: displayedLibrary!)
        } else if let _ = playlist {
            viewController?.displayMovedRow(from: from, to: to, as: .playlist, withDisplayedLibrary: displayedLibrary!)
        }
    }
}
