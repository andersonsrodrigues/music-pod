//
//  AlbumCoreDataWorker.swift
//  MusicPod
//
//  Created by Anderson Rodrigues on 13/04/2020.
//  Copyright © 2020 Anderson Soares Rodrigues. All rights reserved.
//

import Foundation
import CoreData

// MARK: - Album Core Data Protocol

@objc protocol AlbumCoreDataWorkerDelegate {
    
    // MARK: Album update lifecycle
    @objc optional func albumCoreDataWorkerWillUpdate(albumCoreDataWorker: AlbumCoreDataWorker)
    @objc optional func albumCoreDataWorkerDidUpdate(albumCoreDataWorker: AlbumCoreDataWorker)
  
    // MARK: Album section updates
    @objc optional func albumCoreDataWorker(albumCoreDataWorker: AlbumCoreDataWorker, shouldInsertSection section: IndexSet)
    @objc optional func albumCoreDataWorker(albumCoreDataWorker: AlbumCoreDataWorker, shouldDeleteSection section: IndexSet)
    @objc optional func albumCoreDataWorker(albumCoreDataWorker: AlbumCoreDataWorker, shouldUpdateSection section: IndexSet)
    @objc optional func albumCoreDataWorker(albumCoreDataWorker: AlbumCoreDataWorker, shouldMoveSectionFrom from: IndexSet, to: IndexSet)
  
    // MARK: Album row updates
    @objc optional func albumCoreDataWorker(albumCoreDataWorker: AlbumCoreDataWorker, shouldInsertRowAt indexPath: IndexPath)
    @objc optional func albumCoreDataWorker(albumCoreDataWorker: AlbumCoreDataWorker, shouldDeleteRowAt indexPath: IndexPath)
    @objc optional func albumCoreDataWorker(albumCoreDataWorker: AlbumCoreDataWorker, shouldUpdateRowAt indexPath: IndexPath, withAlbum album: Album)
    @objc optional func albumCoreDataWorker(albumCoreDataWorker: AlbumCoreDataWorker, shouldMoveRowFrom from: IndexPath, to: IndexPath, withAlbum album: Album)
}

final class AlbumCoreDataWorker: NSObject, DataWorkerAPI {
    
    // MARK: DatWorkerAPI Protocol Types
    typealias ManagedObject = Album
    typealias Decoder = AlbumData
    
    var delegates = [AlbumCoreDataWorkerDelegate]()
    let viewContext = DataController.shared.viewContext
    
    // MARK: - Object lifecycle
    
    static let shared = AlbumCoreDataWorker()
    private override init() {
        super.init()
        
        setupFetchedResultsController(nil, id: nil)
    }
    
    // MARK: - Core Data stack
    
    var fetchedResultsController: NSFetchedResultsController<Album>!
    
    func setupFetchedResultsController(_ format: String?, id: String?) {
        let fetchRequest: NSFetchRequest<Album> = Album.fetchRequest()
      
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
    
    func validate(album: Album) -> Bool {
        return true
    }
    
    // MARK: - CRUD operations
    
    func create(obj: Decoder) -> ManagedObject {
        let albumModel = Album(context: viewContext)
        albumModel.id = obj.id
        albumModel.name = obj.name
        albumModel.type = obj.type
        albumModel.imageUrl = obj.images?.first?.url
        albumModel.session = obj.session
        
        if let artists = obj.artists {
            for artistData in artists {
                let artistModel = ArtistCoreDataWorker.shared.create(obj: artistData)
                albumModel.addToArtists(artistModel)
            }
        }
        
        try? viewContext.save()
        
        return albumModel
    }
    
    func read(at indexPath: IndexPath) -> ManagedObject {
        return fetchedResultsController.object(at: indexPath)
    }
    
    func update(obj: ManagedObject) {
        guard validate(album: obj) else { return }
        try? viewContext.save()
    }
    
    func delete(at indexPath: IndexPath) {
        let albumModel = read(at: indexPath)
        viewContext.delete(albumModel)
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
        return fetchedResultsController.sections![0].numberOfObjects
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension AlbumCoreDataWorker: NSFetchedResultsControllerDelegate {
  
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegates.forEach { $0.albumCoreDataWorkerWillUpdate?(albumCoreDataWorker: self) }
    }
  
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            delegates.forEach { $0.albumCoreDataWorker?(albumCoreDataWorker: self, shouldInsertSection: IndexSet(integer: sectionIndex)) }
        case .delete:
            delegates.forEach { $0.albumCoreDataWorker?(albumCoreDataWorker: self, shouldDeleteSection: IndexSet(integer: sectionIndex)) }
        default:
            return
        }
    }
  
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            delegates.forEach { $0.albumCoreDataWorker?(albumCoreDataWorker: self, shouldInsertRowAt: newIndexPath!) }
        case .delete:
            delegates.forEach { $0.albumCoreDataWorker?(albumCoreDataWorker: self, shouldDeleteRowAt: indexPath!) }
        case .update:
            let album = anObject as! Album
            delegates.forEach { $0.albumCoreDataWorker?(albumCoreDataWorker: self, shouldUpdateRowAt: indexPath!, withAlbum: album) }
        case .move:
            let album = anObject as! Album
            delegates.forEach { $0.albumCoreDataWorker?(albumCoreDataWorker: self, shouldMoveRowFrom: indexPath!, to: newIndexPath!, withAlbum: album) }
        default:
            return
        }
    }
  
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegates.forEach { $0.albumCoreDataWorkerDidUpdate?(albumCoreDataWorker: self) }
    }
}

