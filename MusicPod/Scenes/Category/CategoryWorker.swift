//
//  CategoryWorker.swift
//  MusicPod
//
//  Created by Anderson Rodrigues on 13/04/2020.
//  Copyright (c) 2020 Anderson Soares Rodrigues. All rights reserved.
//

import UIKit

class CategoryWorker {
    
    private lazy var categoryWorker = { () -> CategoryCoreDataWorker in
        return CategoryModel.categoryWorker
    }()
    
    func fetchCategoryList(completion: @escaping(CategoryModel.List.Response) -> Void ) {
        if categoryWorker.count() > 0 {
            let data = categoryWorker.list()
            let response = CategoryModel.List.Response(categories: data, isError: false, message: nil)
            completion(response)
        } else {
            APIClient.getListOfCategories { (data, error) in
                guard error == nil else {
                    let response = CategoryModel.List.Response(categories: [], isError: true, message: error!.localizedDescription)
                    completion(response)

                    return
                }
                
                for category in data {
                    let categoryModel = self.categoryWorker.create(obj: category)
                }
                
                let response = CategoryModel.List.Response(categories: self.categoryWorker.list(), isError: false, message: nil)
                completion(response)
            }
        }
    }
    
    func fetchRefreshCategoryList(completion: @escaping(CategoryModel.List.Response) -> Void ) {
        APIClient.getListOfCategories { (data, error) in
            guard error == nil else {
                let response = CategoryModel.List.Response(categories: [], isError: true, message: error!.localizedDescription)
                completion(response)

                return
            }
            
            self.categoryWorker.erase()
            
            for category in data {
                let categoryModel = self.categoryWorker.create(obj: category)
            }
            
            let response = CategoryModel.List.Response(categories: self.categoryWorker.list(), isError: false, message: nil)
            completion(response)
        }
    }
    
    func fetchCategoryCoverImage(request: CategoryModel.CoverImage.Request, completion: @escaping(CategoryModel.CoverImage.Response) -> Void ) {
        let object = categoryWorker.read(at: request.indexPath)
        
        if let image = object.icon {
            let entry = Entry(cover: image)
            let response = CategoryModel.CoverImage.Response(entry: entry, cell: request.cell)
            completion(response)
        } else if let url = object.iconUrl {
            APIClient.downloadPosterImage(path: url) { (data, error) in
                if let data = data {
                    object.setValue(data, forKey: "icon")
                    self.categoryWorker.update(obj: object)
                    
                    let entry = Entry(cover: data)
                    let response = CategoryModel.CoverImage.Response(entry: entry, cell: request.cell)
                    completion(response)
                }
            }
        }
    }
}
