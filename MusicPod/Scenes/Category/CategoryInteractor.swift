//
//  CategoryInteractor.swift
//  MusicPod
//
//  Created by Anderson Rodrigues on 13/04/2020.
//  Copyright (c) 2020 Anderson Soares Rodrigues. All rights reserved.
//

import UIKit

// MARK: - Protocol
protocol CategoryBusinessLogic {
    // MARK: Request Handle
    func requestCategoryList(request: CategoryModel.List.Request)
    func requestRefreshCategoryList(request: CategoryModel.List.Request)
    func requestCoverImage(request: CategoryModel.CoverImage.Request)
    
    // MARK: CRUD operations
    func fetchCategoryList(request: CategoryModel.FetchListAndConfigureCell.Request)
    
    // MARK: Count
    func count() -> Int
    
    // MARK: Category update lifecycle
    func startCategoryUpdates(request: CategoryModel.StartCategoryUpdates.Request)
    func stopCategoryUpdates(request: CategoryModel.StopCategoryUpdates.Request)
    
    // MARK: Data Store
    func provideDataStoreToRouter(at indexPath: IndexPath)
}

protocol CategoryDataStore {
    var id: String? { get set }
    var name: String? { get set }
    var category: Category? { get set }
}

class CategoryInteractor: CategoryBusinessLogic, CategoryDataStore {
    var id: String?
    var name: String?
    var category: Category?
    
    var presenter: CategoryPresentationLogic?
    var worker: CategoryWorker?
    var categoryWorker = CategoryModel.categoryWorker
    
    // MARK: Request Categories
    
    func requestCategoryList(request: CategoryModel.List.Request) {
        worker = CategoryWorker()
        
        if let worker = worker {
            worker.fetchCategoryList { (response) in
                self.presenter?.presentCategoryList(response: response)
            }
        }
    }
    
    func requestRefreshCategoryList(request: CategoryModel.List.Request) {
        worker = CategoryWorker()
        
        if let worker = worker {
            worker.fetchRefreshCategoryList { (response) in
                self.presenter?.presentCategoryList(response: response)
            }
        }
    }
    
    func requestCoverImage(request: CategoryModel.CoverImage.Request) {
        worker = CategoryWorker()
        
        if let worker = worker {
            worker.fetchCategoryCoverImage(request: request) { (response) in
                self.presenter?.presentCoverImage(response: response)
            }
        }
    }
    
    // MARK: Count
    
    func count() -> Int {
        return categoryWorker.count()
    }
    
    // MARK: Fetch Results
    
    func fetchCategoryList(request: CategoryModel.FetchListAndConfigureCell.Request) {
        let category = categoryWorker.read(at: request.indexPath)
        
        let response = CategoryModel.FetchListAndConfigureCell.Response(category: category, cell: request.cell, indexPath: request.indexPath)
        presenter?.presentFetchedCategoryListAndConfigureCell(response: response)
    }
    
    // MARK: Data Store
    
    func provideDataStoreToRouter(at indexPath: IndexPath) {
        let categoryData = categoryWorker.read(at: indexPath)
        id = categoryData.id
        name = categoryData.name
        category = categoryData
    }
}

// MARK: - NSFetchedResultsController

extension CategoryInteractor: CategoryCoreDataWorkerDelegate {
    
    // MARK: Category update lifecycle
    
    func startCategoryUpdates(request: CategoryModel.StartCategoryUpdates.Request) {
        categoryWorker.delegates.append(self)
    }
    
    func stopCategoryUpdates(request: CategoryModel.StopCategoryUpdates.Request) {
        if let index = categoryWorker.delegates.firstIndex(where: { $0 === self }) {
            categoryWorker.delegates.remove(at: index)
        }
    }
    
    // MARK: Category row updates
    
    func categoryCoreDataWorker(categoryCoreDataWorker: CategoryCoreDataWorker, shouldInsertRowAt indexPath: IndexPath) {
        presenter?.presentInsertRow(at: indexPath)
    }
    
    func categoryCoreDataWorker(categoryCoreDataWorker: CategoryCoreDataWorker, shouldDeleteRowAt indexPath: IndexPath) {
        presenter?.presentDeleteRow(at: indexPath)
    }
    
    func categoryCoreDataWorker(categoryCoreDataWorker: CategoryCoreDataWorker, shouldUpdateRowAt indexPath: IndexPath, withCategory category: Category) {
        presenter?.presentUpdatedRow(at: indexPath, withCategory: category)
    }
    
    func categoryCoreDataWorker(categoryCoreDataWorker: CategoryCoreDataWorker, shouldMoveRowFrom from: IndexPath, to: IndexPath, withCategory category: Category) {
        presenter?.presentMoveRow(from: from, to: to, withCategory: category)
    }
}

