//
//  TrackCoreDataWorker.swift
//  MusicPod
//
//  Created by Anderson Rodrigues on 13/04/2020.
//  Copyright © 2020 Anderson Soares Rodrigues. All rights reserved.
//

import Foundation
import CoreData

// MARK: - Track Core Data Protocol

@objc protocol TrackCoreDataWorkerDelegate {
    
    // MARK: Track update lifecycle
    @objc optional func trackCoreDataWorkerWillUpdate(trackCoreDataWorker: TrackCoreDataWorker)
    @objc optional func trackCoreDataWorkerDidUpdate(trackCoreDataWorker: TrackCoreDataWorker)
  
    // MARK: Track section updates
    @objc optional func trackCoreDataWorker(trackCoreDataWorker: TrackCoreDataWorker, shouldInsertSection section: IndexSet)
    @objc optional func trackCoreDataWorker(trackCoreDataWorker: TrackCoreDataWorker, shouldDeleteSection section: IndexSet)
    @objc optional func trackCoreDataWorker(trackCoreDataWorker: TrackCoreDataWorker, shouldUpdateSection section: IndexSet)
    @objc optional func trackCoreDataWorker(trackCoreDataWorker: TrackCoreDataWorker, shouldMoveSectionFrom from: IndexSet, to: IndexSet)
  
    // MARK: Track row updates
    @objc optional func trackCoreDataWorker(trackCoreDataWorker: TrackCoreDataWorker, shouldInsertRowAt indexPath: IndexPath)
    @objc optional func trackCoreDataWorker(trackCoreDataWorker: TrackCoreDataWorker, shouldDeleteRowAt indexPath: IndexPath)
    @objc optional func trackCoreDataWorker(trackCoreDataWorker: TrackCoreDataWorker, shouldUpdateRowAt indexPath: IndexPath, withTrack track: Track)
    @objc optional func trackCoreDataWorker(trackCoreDataWorker: TrackCoreDataWorker, shouldMoveRowFrom from: IndexPath, to: IndexPath, withTrack track: Track)
}

final class TrackCoreDataWorker: NSObject, TrackWorkerAPI {
    
    typealias ManagedObject = Track
    typealias ManagedPlaylistMain = Playlist
    typealias ManagedAlbumMain = Album
    typealias ManagedArtistMain = Artist
    typealias Decoder = TrackData
    
    var delegates = [TrackCoreDataWorkerDelegate]()
    let viewContext = DataController.shared.viewContext
    
    // MARK: - Object lifecycle
    
    static let shared = TrackCoreDataWorker()
    private override init() {
        super.init()
        
        setupFetchedResultsController(nil, id: nil)
    }
    
    // MARK: - Core Data stack
    
    var fetchedResultsController: NSFetchedResultsController<Track>!
    
    func setupFetchedResultsController(_ format: String?, id: CVarArg?) {
        let fetchRequest: NSFetchRequest<Track> = Track.fetchRequest()
        
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
    
    func validate(track: Track) -> Bool {
        return true
    }
    
    // MARK: - CRUD operations
    
    func create(obj: Decoder) -> ManagedObject {
        let trackModel = Track(context: viewContext)
        trackModel.id = obj.id
        trackModel.name = obj.name
        trackModel.type = obj.type
        trackModel.previewUrl = obj.previewUrl
        
        for artistData in obj.artists {
            let artist = ArtistCoreDataWorker.shared.create(obj: artistData)
            trackModel.addToArtists(artist)
        }
        
        if let albumData = obj.album {
            let album = AlbumCoreDataWorker.shared.create(obj: albumData)
            trackModel.album = album
        }
        
        try? viewContext.save()
        
        return trackModel
    }
    
    func create(obj: Decoder, main: ManagedPlaylistMain) -> ManagedObject {
        let trackModel = Track(context: viewContext)
        trackModel.id = obj.id
        trackModel.name = obj.name
        trackModel.type = obj.type
        trackModel.previewUrl = obj.previewUrl
        trackModel.playlist = main
        
        for artistData in obj.artists {
            let artist = ArtistCoreDataWorker.shared.create(obj: artistData)
            trackModel.addToArtists(artist)
        }
        
        if let albumData = obj.album {
            let album = AlbumCoreDataWorker.shared.create(obj: albumData)
            trackModel.album = album
        }
        
        try? viewContext.save()
        
        return trackModel
    }
    
    func create(obj: Decoder, main: ManagedAlbumMain) -> ManagedObject {
        let trackModel = Track(context: viewContext)
        trackModel.id = obj.id
        trackModel.name = obj.name
        trackModel.type = obj.type
        trackModel.previewUrl = obj.previewUrl
        trackModel.album = main
        
        for artistData in obj.artists {
            let artist = ArtistCoreDataWorker.shared.create(obj: artistData)
            trackModel.addToArtists(artist)
        }
        
        try? viewContext.save()
        
        return trackModel
    }
    
    func read(at indexPath: IndexPath) -> ManagedObject {
        return fetchedResultsController.object(at: indexPath)
    }
    
    func update(obj: ManagedObject) {
        guard validate(track: obj) else { return }
        try? viewContext.save()
    }
    
    func delete(at indexPath: IndexPath) {
        let trackModel = read(at: indexPath)
        viewContext.delete(trackModel)
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
        if let trackObjects = fetchedResultsController.fetchedObjects {
            for obj in trackObjects {
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
extension TrackCoreDataWorker: NSFetchedResultsControllerDelegate {
  
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegates.forEach { $0.trackCoreDataWorkerWillUpdate?(trackCoreDataWorker: self) }
    }
  
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            delegates.forEach { $0.trackCoreDataWorker?(trackCoreDataWorker: self, shouldInsertSection: IndexSet(integer: sectionIndex)) }
        case .delete:
            delegates.forEach { $0.trackCoreDataWorker?(trackCoreDataWorker: self, shouldDeleteSection: IndexSet(integer: sectionIndex)) }
        default:
            return
        }
    }
  
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            delegates.forEach { $0.trackCoreDataWorker?(trackCoreDataWorker: self, shouldInsertRowAt: newIndexPath!) }
        case .delete:
            delegates.forEach { $0.trackCoreDataWorker?(trackCoreDataWorker: self, shouldDeleteRowAt: indexPath!) }
        case .update:
            let track = anObject as! Track
            delegates.forEach { $0.trackCoreDataWorker?(trackCoreDataWorker: self, shouldUpdateRowAt: indexPath!, withTrack: track) }
        case .move:
            let track = anObject as! Track
            delegates.forEach { $0.trackCoreDataWorker?(trackCoreDataWorker: self, shouldMoveRowFrom: indexPath!, to: newIndexPath!, withTrack: track) }
        default:
            return
        }
    }
  
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegates.forEach { $0.trackCoreDataWorkerDidUpdate?(trackCoreDataWorker: self) }
    }
}
