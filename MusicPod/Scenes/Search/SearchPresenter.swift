//
//  SearchPresenter.swift
//  MusicPod
//
//  Created by Anderson Rodrigues on 15/04/2020.
//  Copyright (c) 2020 Anderson Soares Rodrigues. All rights reserved.
//

import UIKit

// MARK: - Protocol
protocol SearchPresentationLogic {
    // MARK: Fetch entries
	func presentSearchList(response: SearchModel.List.Response)
    func presentCoverImage(response: SearchModel.CoverImage.Response)
}

class SearchPresenter: SearchPresentationLogic {
	weak var viewController: SearchDisplayLogic?
	
	// MARK: Fetch entries
	
	func presentSearchList(response: SearchModel.List.Response) {
        let displayedEntries = response.search.map { convert(entry: $0) }
        let viewModel = SearchModel.List.ViewModel(displayedEntries: displayedEntries, isError: response.isError, message: response.message)
        
        if response.isError {
            viewController?.displayErrorSearchList(viewModel: viewModel)
        } else {
            viewController?.displaySearchList(viewModel: viewModel)
        }
	}
    
    func presentCoverImage(response: SearchModel.CoverImage.Response) {
        let displayImage = convert(entry: response.entry)
        let viewModel = SearchModel.CoverImage.ViewModel(displayedEntry: displayImage, cell: response.cell)
        viewController?.displayCoverImage(viewModel: viewModel)
    }
    
    // MARK: Format search to displayed cell
    
    private func convert(entry: Search) -> SearchModel.DisplayedCell {
        return SearchModel.DisplayedCell(id: entry.id, name: entry.name, type: entry.type!, image: nil, url: entry.images?.first?.url)
    }
    
    private func convert(entry: Entry) -> SearchModel.DisplayedImage {
        let image = UIImage(data: entry.cover)
        return SearchModel.DisplayedImage(cover: image!)
    }
}
