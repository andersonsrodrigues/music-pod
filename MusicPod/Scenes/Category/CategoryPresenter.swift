//
//  CategoryPresenter.swift
//  MusicPod
//
//  Created by Anderson Rodrigues on 13/04/2020.
//  Copyright (c) 2020 Anderson Soares Rodrigues. All rights reserved.
//

import UIKit

// MARK: - Protocol
protocol CategoryPresentationLogic {
    // MARK: Fetch Handle
    func presentCategoryList(response: CategoryModel.List.Response)
    func presentCoverImage(response: CategoryModel.CoverImage.Response)
    
    // MARK: CRUD operations
    func presentFetchedCategoryListAndConfigureCell(response: CategoryModel.FetchListAndConfigureCell.Response)
    
    // MARK: Category row updates
    func presentInsertRow(at indexPath: IndexPath)
    func presentDeleteRow(at indexPath: IndexPath)
    func presentUpdatedRow(at indexPath: IndexPath, withCategory category: Category)
    func presentMoveRow(from: IndexPath, to: IndexPath, withCategory category: Category)
}

class CategoryPresenter: CategoryPresentationLogic {
    weak var viewController: CategoryDisplayLogic?
    
    // MARK: Request Category List
    
    func presentCategoryList(response: CategoryModel.List.Response) {
        let viewModel = CategoryModel.List.ViewModel(categories: response.categories, isError: response.isError, message: response.message)
        
        if response.isError {
            viewController?.displayErrorFetchCategoryList(viewModel: viewModel)
        } else {
            viewController?.displayCategoryList(viewModel: viewModel)
        }
    }
    
    // MARK: Request Cover Image
    
    func presentCoverImage(response: CategoryModel.CoverImage.Response) {
        let displayEntry = convert(entry: response.entry)
        let viewModel = CategoryModel.CoverImage.ViewModel(displayedEntry: displayEntry, cell: response.cell)
        viewController?.displayCoverImage(viewModel: viewModel)
    }
    
    // MARK: CRUD operation
    
    func presentFetchedCategoryListAndConfigureCell(response: CategoryModel.FetchListAndConfigureCell.Response) {
        let displayCategoryList = formatCell(category: response.category)
        
        let viewModel = CategoryModel.FetchListAndConfigureCell.ViewModel(displayedCategory: displayCategoryList, cell: response.cell!, indexPath: response.indexPath)
        viewController?.displayFetchedCategoryListAndConfigureCell(viewModel: viewModel)
    }
    
    // MARK: Format entry to displayed entry
    
    private func convert(entry: Entry) -> CategoryModel.DisplayedEntry {
        let image = UIImage(data: entry.cover)
        return CategoryModel.DisplayedEntry(cover: image!)
    }
    
    // MARK: - Format Artist & Album & Playlist
    
    private func formatCell(category: Category) -> CategoryModel.DisplayedCell {
        return CategoryModel.DisplayedCell(name: category.name!, image: category.icon, url: category.iconUrl)
    }
}

// MARK: - NSFetchedResultsController

extension CategoryPresenter {
    // MARK: Category row updates
    
    func presentInsertRow(at indexPath: IndexPath) {
        viewController?.displayInsertedRow(at: indexPath)
    }
    
    func presentDeleteRow(at indexPath: IndexPath) {
        viewController?.displayDeletedRow(at: indexPath)
    }
    
    func presentUpdatedRow(at indexPath: IndexPath, withCategory category: Category) {
        let displayedCategory = formatCell(category: category)
        viewController?.displayUpdatedRow(at: indexPath, withDisplayedCategory: displayedCategory)
    }
    
    func presentMoveRow(from: IndexPath, to: IndexPath, withCategory category: Category) {
        let displayedCategory = formatCell(category: category)
        viewController?.displayMovedRow(from: from, to: to, withDisplayedCategory: displayedCategory)
    }
}
