//
//  CategoryModels.swift
//  MusicPod
//
//  Created by Anderson Rodrigues on 13/04/2020.
//  Copyright (c) 2020 Anderson Soares Rodrigues. All rights reserved.
//

import UIKit

enum CategoryModel {
    
    // MARK: - External Workers
    
    static var categoryWorker = CategoryCoreDataWorker.shared
    
    // MARK: - Model
    struct DisplayedCell {
        var name: String
        var image: Data?
        var url: String?
    }
    
    struct DisplayedEntry {
        var cover: UIImage
    }
    
    // MARK: - CRUD operations
    
    enum List {
        struct Request {}
        struct Response {
            var categories: [Category]
            var isError: Bool
            var message: String?
        }
        struct ViewModel {
            var categories: [Category]
            var isError: Bool
            var message: String?
        }
    }
    
    enum FetchListAndConfigureCell {
        struct Request {
            var indexPath: IndexPath
            var cell: CategoryCollectionViewCell?
        }
        struct Response {
            var category: Category
            var cell: CategoryCollectionViewCell?
            var indexPath: IndexPath
        }
        struct ViewModel {
            var displayedCategory: DisplayedCell
            var cell: CategoryCollectionViewCell?
            var indexPath: IndexPath
        }
    }
    
    enum CoverImage {
        struct Request {
            var url: String
            var cell: CategoryCollectionViewCell
            var indexPath: IndexPath
        }
        struct Response {
            var entry: Entry
            var cell: CategoryCollectionViewCell
        }
        struct ViewModel {
            var displayedEntry: DisplayedEntry
            var cell: CategoryCollectionViewCell
        }
    }
    
    // MARK: - Category update lifecycle
    
    enum StartCategoryUpdates {
        struct Request { }
        struct Response { }
        struct ViewModel { }
    }
    
    enum StopCategoryUpdates {
        struct Request { }
        struct Response { }
        struct ViewModel { }
    }
}
