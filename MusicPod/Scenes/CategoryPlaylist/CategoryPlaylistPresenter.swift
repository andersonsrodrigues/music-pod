//
//  CategoryPlaylistPresenter.swift
//  MusicPod
//
//  Created by Anderson Rodrigues on 13/04/2020.
//  Copyright (c) 2020 Anderson Soares Rodrigues. All rights reserved.
//

import UIKit

// MARK: - Protocol
protocol CategoryPlaylistPresentationLogic {
    // MARK: Fetch Handle
    func presentCategoryPlaylistList(response: CategoryPlaylistModel.List.Response)
    func presentCoverImage(response: CategoryPlaylistModel.CoverImage.Response)
    
    // MARK: CRUD operations
    func presentFetchedCategoryPlaylistListAndConfigureCell(response: CategoryPlaylistModel.FetchListAndConfigureCell.Response)
    
    // MARK: Category Playlist row updates
    func presentInsertRow(at indexPath: IndexPath)
    func presentDeleteRow(at indexPath: IndexPath)
    func presentUpdatedRow(at indexPath: IndexPath, withPlaylist playlist: Playlist)
    func presentMoveRow(from: IndexPath, to: IndexPath, withPlaylist playlist: Playlist)
}

class CategoryPlaylistPresenter: CategoryPlaylistPresentationLogic {
    weak var viewController: CategoryPlaylistDisplayLogic?
    
    // MARK: Present Category Playlist List
    func presentCategoryPlaylistList(response: CategoryPlaylistModel.List.Response) {
        let viewModel = CategoryPlaylistModel.List.ViewModel(playlists: response.playlists, isError: response.isError, message: response.message)
        
        if response.isError {
            viewController?.displayErrorFetchCategoryPlaylistList(viewModel: viewModel)
        } else {
            viewController?.displayCategoryPlaylistList(viewModel: viewModel)
        }
    }
    
    // MARK: Present Cover Image
    
    func presentCoverImage(response: CategoryPlaylistModel.CoverImage.Response) {
        let displayedEntry = convert(entry: response.entry)
        let viewModel = CategoryPlaylistModel.CoverImage.ViewModel(displayedEntry: displayedEntry, cell: response.cell)
        viewController?.displayCoverImage(viewModel: viewModel)
    }
    
    // MARK: CRUD operation
    
    func presentFetchedCategoryPlaylistListAndConfigureCell(response: CategoryPlaylistModel.FetchListAndConfigureCell.Response) {
        let displayedPlaylist = formatCell(playlist: response.playlist)
        let viewModel = CategoryPlaylistModel.FetchListAndConfigureCell.ViewModel(displayedPlaylist: displayedPlaylist, indexPath: response.indexPath, cell: response.cell)
        viewController?.displayFetchedCategoryPlaylistListAndConfigureCell(viewModel: viewModel)
    }
    
    // MARK: Format entry to displayed entry
    
    private func convert(entry: Entry) -> CategoryPlaylistModel.DisplayedEntry {
        let image = UIImage(data: entry.cover)
        return CategoryPlaylistModel.DisplayedEntry(cover: image!)
    }
    
    // MARK: - Format Artist & Album & Playlist
    
    private func formatCell(playlist: Playlist) -> CategoryPlaylistModel.DisplayedCell {
        return CategoryPlaylistModel.DisplayedCell(image: playlist.image, url: playlist.imageUrl)
    }
}

// MARK: - NSFetchedResultsController

extension CategoryPlaylistPresenter {
    // MARK: Category row updates
    
    func presentInsertRow(at indexPath: IndexPath) {
        viewController?.displayInsertedRow(at: indexPath)
    }
    
    func presentDeleteRow(at indexPath: IndexPath) {
        viewController?.displayDeletedRow(at: indexPath)
    }
    
    func presentUpdatedRow(at indexPath: IndexPath, withPlaylist playlist: Playlist) {
        let displayedPlaylist = formatCell(playlist: playlist)
        viewController?.displayUpdatedRow(at: indexPath, withDisplayedPlaylist: displayedPlaylist)
    }
    
    func presentMoveRow(from: IndexPath, to: IndexPath, withPlaylist playlist: Playlist) {
        let displayedPlaylist = formatCell(playlist: playlist)
        viewController?.displayMovedRow(from: from, to: to, withDisplayedPlaylist: displayedPlaylist)
    }
}
