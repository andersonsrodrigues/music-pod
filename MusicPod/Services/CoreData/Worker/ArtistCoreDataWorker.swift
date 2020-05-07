//
//  ArtistCoreDataWorker.swift
//  MusicPod
//
//  Created by Anderson Rodrigues on 13/04/2020.
//  Copyright © 2020 Anderson Soares Rodrigues. All rights reserved.
//

import Foundation
import CoreData

// MARK: - Artist Core Data Protocol

@objc protocol ArtistCoreDataWorkerDelegate {
    
    // MARK: Artist update lifecycle
    @objc optional func artistCoreDataWorkerWillUpdate(artistCoreDataWorker: ArtistCoreDataWorker)
    @objc optional func artistCoreDataWorkerDidUpdate(artistCoreDataWorker: ArtistCoreDataWorker)
  
    // MARK: Artist section updates
    @objc optional func artistCoreDataWorker(artistCoreDataWorker: ArtistCoreDataWorker, shouldInsertSection section: IndexSet)
    @objc optional func artistCoreDataWorker(artistCoreDataWorker: ArtistCoreDataWorker, shouldDeleteSection section: IndexSet)
    @objc optional func artistCoreDataWorker(artistCoreDataWorker: ArtistCoreDataWorker, shouldUpdateSection section: IndexSet)
    @objc optional func artistCoreDataWorker(artistCoreDataWorker: ArtistCoreDataWorker, shouldMoveSectionFrom from: IndexSet, to: IndexSet)
  
    // MARK: Artist row updates
    @objc optional func artistCoreDataWorker(artistCoreDataWorker: ArtistCoreDataWorker, shouldInsertRowAt indexPath: IndexPath)
    @objc optional func artistCoreDataWorker(artistCoreDataWorker: ArtistCoreDataWorker, shouldDeleteRowAt indexPath: IndexPath)
    @objc optional func artistCoreDataWorker(artistCoreDataWorker: ArtistCoreDataWorker, shouldUpdateRowAt indexPath: IndexPath, withArtist artist: Artist)
    @objc optional func artistCoreDataWorker(artistCoreDataWorker: ArtistCoreDataWorker, shouldMoveRowFrom from: IndexPath, to: IndexPath, withArtist artist: Artist)
}

final class ArtistCoreDataWorker: NSObject, DataWorkerAPI {
    
    // MARK: DatWorkerAPI Protocol Types
    typealias ManagedObject = Artist
    typealias Decoder = ArtistData
    
    var delegates = [ArtistCoreDataWorkerDelegate]()
    let viewContext = DataController.shared.viewContext
    
    // MARK: - Object lifecycle
    
    static let shared = ArtistCoreDataWorker()
    private override init() {
        super.init()
        
        setupFetchedResultsController(nil, id: nil)
    }
    
    // MARK: - Core Data stack
    
    var fetchedResultsController: NSFetchedResultsController<Artist>!
    
    func setupFetchedResultsController(_ format: String?, id: String?) {
        let fetchRequest: NSFetchRequest<Artist> = Artist.fetchRequest()
      
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
    
    func validate(artist: Artist) -> Bool {
        return true
    }
    
    // MARK: - CRUD operations
    
    func show(at indexPath: IndexPath) -> ManagedObject {
        return fetchedResultsController.object(at: indexPath)
    }
    
    func create(obj: Decoder) -> ManagedObject {
        let artistModel = Artist(context: viewContext)
        artistModel.id = obj.id
        artistModel.name = obj.name
        artistModel.followers = Int32(exactly: NSNumber(value: obj.followers?.total ?? 0)) ?? 0
        artistModel.type = obj.type
        artistModel.imageUrl = obj.images?.first?.url
        artistModel.session = obj.session
        
        try? viewContext.save()
        
        return artistModel
    }
    
    func read(at indexPath: IndexPath) -> ManagedObject {
        return fetchedResultsController.object(at: indexPath)
    }
    
    func update(obj: ManagedObject) {
        guard validate(artist: obj) else { return }
        try? viewContext.save()
    }
    
    func delete(at indexPath: IndexPath) {
        let artistModel = read(at: indexPath)
        viewContext.delete(artistModel)
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
        if let albumObjects = fetchedResultsController.fetchedObjects {
            for obj in albumObjects {
                viewContext.delete(obj)
            }
        }
        try? viewContext.save()
    }
    
    // MARK: - Count
    
    func count() -> Int {
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension ArtistCoreDataWorker: NSFetchedResultsControllerDelegate {
  
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegates.forEach { $0.artistCoreDataWorkerWillUpdate?(artistCoreDataWorker: self) }
    }
  
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            delegates.forEach { $0.artistCoreDataWorker?(artistCoreDataWorker: self, shouldInsertSection: IndexSet(integer: sectionIndex)) }
        case .delete:
            delegates.forEach { $0.artistCoreDataWorker?(artistCoreDataWorker: self, shouldDeleteSection: IndexSet(integer: sectionIndex)) }
        default:
            return
        }
    }
  
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            delegates.forEach { $0.artistCoreDataWorker?(artistCoreDataWorker: self, shouldInsertRowAt: newIndexPath!) }
        case .delete:
            delegates.forEach { $0.artistCoreDataWorker?(artistCoreDataWorker: self, shouldDeleteRowAt: indexPath!) }
        case .update:
            let artist = anObject as! Artist
            delegates.forEach { $0.artistCoreDataWorker?(artistCoreDataWorker: self, shouldUpdateRowAt: indexPath!, withArtist: artist) }
        case .move:
            let artist = anObject as! Artist
            delegates.forEach { $0.artistCoreDataWorker?(artistCoreDataWorker: self, shouldMoveRowFrom: indexPath!, to: newIndexPath!, withArtist: artist) }
        default:
            return
        }
    }
  
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegates.forEach { $0.artistCoreDataWorkerDidUpdate?(artistCoreDataWorker: self) }
    }
}
