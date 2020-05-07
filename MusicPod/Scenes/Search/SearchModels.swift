//
//  SearchModels.swift
//  MusicPod
//
//  Created by Anderson Rodrigues on 15/04/2020.
//  Copyright (c) 2020 Anderson Soares Rodrigues. All rights reserved.
//

import UIKit

enum SearchModel {
	
    // MARK: - Model
    struct DisplayedCell {
        var id: String
        var name: String
        var type: String
        var image: Data?
        var url: String?
    }
    
    struct DisplayedImage {
        var cover: UIImage
    }
	
    // MARK: - CRUD operations
    
    enum List {
        struct Request {
            var query: String
        }
        struct Response {
            var search: [Search]
            var isError: Bool
            var message: String?
        }
        struct ViewModel {
            var displayedEntries: [DisplayedCell]
            var isError: Bool
            var message: String?
        }
    }
    
    enum CoverImage {
        struct Request {
            var url: String
            var cell: SearchResultTableViewCell
            var indexPath: IndexPath
        }
        struct Response {
            var entry: Entry
            var cell: SearchResultTableViewCell
        }
        struct ViewModel {
            var displayedEntry: DisplayedImage
            var cell: SearchResultTableViewCell
        }
    }
}
