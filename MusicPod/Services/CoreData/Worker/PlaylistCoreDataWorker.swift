//
//  PlaylistCoreDataWorker.swift
//  MusicPod
//
//  Created by Anderson Rodrigues on 13/04/2020.
//  Copyright © 2020 Anderson Soares Rodrigues. All rights reserved.
//

import Foundation
import CoreData

// MARK: - Playlist Core Data protocol

@objc protocol PlaylistCoreDataWorkerDelegate {
    
    // MARK: Playlist update lifecycle
    @objc optional func playlistCoreDataWorkerWillUpdate(playlistCoreDataWorker: PlaylistCoreDataWorker)
    @objc optional func playlistCoreDataWorkerDidUpdate(playlistCoreDataWorker: PlaylistCoreDataWorker)
  
    // MARK: Playlist section updates
    @objc optional func playlistCoreDataWorker(playlistCoreDataWorker: PlaylistCoreDataWorker, shouldInsertSection section: IndexSet)
    @objc optional func playlistCoreDataWorker(playlistCoreDataWorker: PlaylistCoreDataWorker, shouldDeleteSection section: IndexSet)
    @objc optional func playlistCoreDataWorker(playlistCoreDataWorker: PlaylistCoreDataWorker, shouldUpdateSection section: IndexSet)
    @objc optional func playlistCoreDataWorker(playlistCoreDataWorker: PlaylistCoreDataWorker, shouldMoveSectionFrom from: IndexSet, to: IndexSet)
  
    // MARK: Playlist row updates
    @objc optional func playlistCoreDataWorker(playlistCoreDataWorker: PlaylistCoreDataWorker, shouldInsertRowAt indexPath: IndexPath)
    @objc optional func playlistCoreDataWorker(playlistCoreDataWorker: PlaylistCoreDataWorker, shouldDeleteRowAt indexPath: IndexPath)
    @objc optional func playlistCoreDataWorker(playlistCoreDataWorker: PlaylistCoreDataWorker, shouldUpdateRowAt indexPath: IndexPath, withPlaylist playlist: Playlist)
    @objc optional func playlistCoreDataWorker(playlistCoreDataWorker: PlaylistCoreDataWorker, shouldMoveRowFrom from: IndexPath, to: IndexPath, withPlaylist playlist: Playlist)
}

final class PlaylistCoreDataWorker: NSObject, PlaylistWorkerAPI {
    
    typealias ManagedObject = Playlist
    typealias Decoder = PlaylistData
    typealias DecoderFull = PlaylistFullData
    typealias DecoderSimplified = PlaylistSimplifiedData
    
    var delegates = [PlaylistCoreDataWorkerDelegate]()
    let viewContext = DataController.shared.viewContext
    
    // MARK: - Object lifecycle
    
    static let shared = PlaylistCoreDataWorker()
    private override init() {
        super.init()
        
        setupFetchedResultsController(nil, id: nil)
    }
    
    // MARK: - Core Data stack
    
    var fetchedResultsController: NSFetchedResultsController<Playlist>!
    
    func setupFetchedResultsController(_ format: String?, id: CVarArg?) {
        let fetchRequest: NSFetchRequest<Playlist> = Playlist.fetchRequest()
        
        if let format = format, let id = id {
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
    
    func validate(playlist: Playlist) -> Bool {
        return true
    }
    
    // MARK: - CRUD operations
    
    func create(obj: Decoder) -> ManagedObject {
        let playlistModel = Playlist(context: viewContext)
        playlistModel.id = obj.id
        playlistModel.name = obj.name
        playlistModel.desc = obj.description
        playlistModel.type = obj.type
        playlistModel.imageUrl = obj.images?.first?.url
        playlistModel.session = obj.session
        
        try? viewContext.save()
        
        return playlistModel
    }
    
    func create(obj: DecoderFull) -> ManagedObject {
        let playlistModel = Playlist(context: viewContext)
        playlistModel.id = obj.id
        playlistModel.name = obj.name
        playlistModel.desc = obj.description
        playlistModel.type = obj.type
        playlistModel.imageUrl = obj.images?.first?.url
        playlistModel.session = obj.session
        
        if let tracks = obj.tracks {
            for trackData in tracks.items {
                if let track = trackData.track {
                    let trackModel = TrackCoreDataWorker.shared.create(obj: track, main: playlistModel)
                    playlistModel.addToTracks(trackModel)
                }
            }
        }
        
        try? viewContext.save()
        
        return playlistModel
    }
    
    func create(obj: DecoderSimplified) -> ManagedObject {
        let playlistModel = Playlist(context: viewContext)
        playlistModel.id = obj.id
        playlistModel.name = obj.name
        playlistModel.desc = obj.description
        playlistModel.type = obj.type
        playlistModel.imageUrl = obj.images?.first?.url
        playlistModel.session = obj.session
        
        if let trackData = obj.tracks {
            if let track = trackData.track {
                let trackModel = TrackCoreDataWorker.shared.create(obj: track, main: playlistModel)
                playlistModel.addToTracks(trackModel)
            }
        }
        
        try? viewContext.save()
        
        return playlistModel
    }
    
    func read(at indexPath: IndexPath) -> ManagedObject {
        return fetchedResultsController.object(at: indexPath)
    }
    
    func update(obj: ManagedObject) {
        guard validate(playlist: obj) else { return }
        try? viewContext.save()
    }
    
    func delete(at indexPath: IndexPath) {
        let playlistModel = read(at: indexPath)
        viewContext.delete(playlistModel)
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
        if let playlistObjects = fetchedResultsController.fetchedObjects {
            for obj in playlistObjects {
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
extension PlaylistCoreDataWorker: NSFetchedResultsControllerDelegate {
  
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegates.forEach { $0.playlistCoreDataWorkerWillUpdate?(playlistCoreDataWorker: self) }
    }
  
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            delegates.forEach { $0.playlistCoreDataWorker?(playlistCoreDataWorker: self, shouldInsertSection: IndexSet(integer: sectionIndex)) }
        case .delete:
            delegates.forEach { $0.playlistCoreDataWorker?(playlistCoreDataWorker: self, shouldDeleteSection: IndexSet(integer: sectionIndex)) }
        default:
            return
        }
    }
  
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            delegates.forEach { $0.playlistCoreDataWorker?(playlistCoreDataWorker: self, shouldInsertRowAt: newIndexPath!) }
        case .delete:
            delegates.forEach { $0.playlistCoreDataWorker?(playlistCoreDataWorker: self, shouldDeleteRowAt: indexPath!) }
        case .update:
            let playlist = anObject as! Playlist
            delegates.forEach { $0.playlistCoreDataWorker?(playlistCoreDataWorker: self, shouldUpdateRowAt: indexPath!, withPlaylist: playlist) }
        case .move:
            let playlist = anObject as! Playlist
            delegates.forEach { $0.playlistCoreDataWorker?(playlistCoreDataWorker: self, shouldMoveRowFrom: indexPath!, to: newIndexPath!, withPlaylist: playlist) }
        default:
            return
        }
    }
  
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegates.forEach { $0.playlistCoreDataWorkerDidUpdate?(playlistCoreDataWorker: self) }
    }
}
