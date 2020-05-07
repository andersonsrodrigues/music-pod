//
//  Track.swift
//  MusicPod
//
//  Created by Anderson Rodrigues on 19/03/2020.
//  Copyright © 2020 Anderson Rodrigues. All rights reserved.
//

import Foundation
import CoreData

extension Track {
    func getAllArtists() -> String {
        var names = [String]()
        
        if let artists = self.artists?.allObjects as? [Artist] {
            for artist in artists {
                if let name = artist.name {
                    names.append(name)
                }
            }
        }
        
        return names.joined(separator: ", ")
    }
}
