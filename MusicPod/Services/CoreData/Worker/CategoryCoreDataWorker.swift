//
//  CategoryCoreDataWorker.swift
//  MusicPod
//
//  Created by Anderson Rodrigues on 13/04/2020.
//  Copyright © 2020 Anderson Soares Rodrigues. All rights reserved.
//

import Foundation
import CoreData

// MARK: - Category Core Data Protocol

@objc protocol CategoryCoreDataWorkerDelegate {
    
    // MARK: Category update lifecycle
    @objc optional func categoryCoreDataWorkerWillUpdate(categoryCoreDataWorker: CategoryCoreDataWorker)
    @objc optional func categoryCoreDataWorkerDidUpdate(categoryCoreDataWorker: CategoryCoreDataWorker)
  
    // MARK: Category section updates
    @objc optional func categoryCoreDataWorker(categoryCoreDataWorker: CategoryCoreDataWorker, shouldInsertSection section: IndexSet)
    @objc optional func categoryCoreDataWorker(categoryCoreDataWorker: CategoryCoreDataWorker, shouldDeleteSection section: IndexSet)
    @objc optional func categoryCoreDataWorker(categoryCoreDataWorker: CategoryCoreDataWorker, shouldUpdateSection section: IndexSet)
    @objc optional func categoryCoreDataWorker(categoryCoreDataWorker: CategoryCoreDataWorker, shouldMoveSectionFrom from: IndexSet, to: IndexSet)
  
    // MARK: Category row updates
    @objc optional func categoryCoreDataWorker(categoryCoreDataWorker: CategoryCoreDataWorker, shouldInsertRowAt indexPath: IndexPath)
    @objc optional func categoryCoreDataWorker(categoryCoreDataWorker: CategoryCoreDataWorker, shouldDeleteRowAt indexPath: IndexPath)
    @objc optional func categoryCoreDataWorker(categoryCoreDataWorker: CategoryCoreDataWorker, shouldUpdateRowAt indexPath: IndexPath, withCategory category: Category)
    @objc optional func categoryCoreDataWorker(categoryCoreDataWorker: CategoryCoreDataWorker, shouldMoveRowFrom from: IndexPath, to: IndexPath, withCategory category: Category)
}

final class CategoryCoreDataWorker: NSObject, DataWorkerAPI {
    
    // MARK: DatWorkerAPI Protocol Types
    typealias ManagedObject = Category
    typealias Decoder = CategoryData
    
    var delegates = [CategoryCoreDataWorkerDelegate]()
    let viewContext = DataController.shared.viewContext
    
    // MARK: - Object lifecycle
    
    static let shared = CategoryCoreDataWorker()
    private override init() {
        super.init()
        
        setupFetchedResultsController(nil, id: nil)
    }
    
    // MARK: - Core Data stack
    
    var fetchedResultsController: NSFetchedResultsController<Category>!
    
    func setupFetchedResultsController(_ format: String?, id: String?) {
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        
        if let id = id, let format = format {
            let predicate = NSPredicate(format: format, id)
            fetchRequest.predicate = predicate
        }
      
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
      
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController!.delegate = self
      
        do {
            try fetchedResultsController!.performFetch()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    // MARK: - Validation
    
    func validate(category: Category) -> Bool {
        return true
    }
    
    // MARK: - CRUD operations
    
    func create(obj: Decoder) -> ManagedObject {
        let categoryModel = Category(context: viewContext)
        categoryModel.id = obj.id
        categoryModel.name = obj.name
        categoryModel.iconUrl = obj.icons.first?.url
        
        try? viewContext.save()
        
        return categoryModel
    }
    
    func read(at indexPath: IndexPath) -> ManagedObject {
        return fetchedResultsController.object(at: indexPath)
    }
    
    func update(obj: ManagedObject) {
        guard validate(category: obj) else { return }
        try? viewContext.save()
    }
    
    func delete(at indexPath: IndexPath) {
        let categoryModel = read(at: indexPath)
        viewContext.delete(categoryModel)
        try? viewContext.save()
    }
    
    // MARK: CRUD operations extra
    
    func list() -> [ManagedObject] {
        do {
            try fetchedResultsController.performFetch()
            return fetchedResultsController.fetchedObjects!.map { $0 }
        } catch {
            fatalError("Unresolved error \(error), \(error.localizedDescription)")
        }
    }
    
    func erase() {
        if let categoryObjects = fetchedResultsController.fetchedObjects {
            for obj in categoryObjects {
                viewContext.delete(obj)
            }
        }
        try? viewContext.save()
    }
    
    // MARK: - Count
    
    func count() -> Int {
        return fetchedResultsController.sections![0].numberOfObjects
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension CategoryCoreDataWorker: NSFetchedResultsControllerDelegate {
  
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegates.forEach { $0.categoryCoreDataWorkerWillUpdate?(categoryCoreDataWorker: self) }
    }
  
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            delegates.forEach { $0.categoryCoreDataWorker?(categoryCoreDataWorker: self, shouldInsertSection: IndexSet(integer: sectionIndex)) }
        case .delete:
            delegates.forEach { $0.categoryCoreDataWorker?(categoryCoreDataWorker: self, shouldDeleteSection: IndexSet(integer: sectionIndex)) }
        default:
            return
        }
    }
  
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            delegates.forEach { $0.categoryCoreDataWorker?(categoryCoreDataWorker: self, shouldInsertRowAt: newIndexPath!) }
        case .delete:
            delegates.forEach { $0.categoryCoreDataWorker?(categoryCoreDataWorker: self, shouldDeleteRowAt: indexPath!) }
        case .update:
            let category = anObject as! Category
            delegates.forEach { $0.categoryCoreDataWorker?(categoryCoreDataWorker: self, shouldUpdateRowAt: indexPath!, withCategory: category) }
        case .move:
            let category = anObject as! Category
            delegates.forEach { $0.categoryCoreDataWorker?(categoryCoreDataWorker: self, shouldMoveRowFrom: indexPath!, to: newIndexPath!, withCategory: category) }
        default:
            return
        }
    }
  
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegates.forEach { $0.categoryCoreDataWorkerDidUpdate?(categoryCoreDataWorker: self) }
    }
}
