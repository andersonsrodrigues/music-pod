//
//  DataWorkerAPI.swift
//  MusicPod
//
//  Created by Anderson Rodrigues on 13/04/2020.
//  Copyright © 2020 Anderson Soares Rodrigues. All rights reserved.
//

import Foundation

// MARK: - Data Methods
protocol DataWorkerAPI {
    
    associatedtype ManagedObject
    associatedtype Decoder
    
    // MARK: CRUD operations
  
    func create(obj: Decoder) -> ManagedObject
    func read(at indexPath: IndexPath) -> ManagedObject
    func update(obj: ManagedObject)
    func delete(at indexPath: IndexPath)
    
    // MARK: CRUD operations extra
    func list() -> [ManagedObject]
    func erase()
  
    // MARK: Count
  
    func count() -> Int
}
// MARK: - Playlist Methods
protocol PlaylistWorkerAPI: DataWorkerAPI {
    
    associatedtype DecoderFull
    associatedtype DecoderSimplified
    
    // MARK: CRUD operations
  
    func create(obj: DecoderFull) -> ManagedObject
    func create(obj: DecoderSimplified) -> ManagedObject
}

// MARK: - Track Methods
protocol TrackWorkerAPI: DataWorkerAPI {
    
    associatedtype ManagedPlaylistMain
    associatedtype ManagedAlbumMain
    associatedtype ManagedArtistMain
    
    // MARK: CRUD operations
  
    func create(obj: Decoder, main: ManagedPlaylistMain) -> ManagedObject
    func create(obj: Decoder, main: ManagedAlbumMain) -> ManagedObject
}
