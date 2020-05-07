//
//  DataController.swift
//  Mooskine
//
//  Created by Kathryn Rotondo on 10/11/17.
//  Copyright © 2017 Udacity. All rights reserved.
//

import Foundation
import CoreData

class DataController {
    
    static let shared = DataController()
    
    lazy var persistentContainer:NSPersistentContainer = {
        let persistentContainer = NSPersistentContainer(name: "MusicPod")
        
        return persistentContainer
    }()
    
    var viewContext:NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func configureContexts() {
        viewContext.automaticallyMergesChangesFromParent = true
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
    }
    
    func load(completion: (() -> Void)? = nil) {
        persistentContainer.loadPersistentStores { storeDescription, error in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            
            self.configureContexts()
            completion?()
        }
    }
    
    func save() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                fatalError("Unresolved error \(error), \(error.localizedDescription)")
            }
        }
    }
}
