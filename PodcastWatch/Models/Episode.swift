//
//  Episode.swift
//  PodcastWatch
//
//  Created by Samantha John on 12/25/15.
//  Copyright © 2015 SamanthaJohn. All rights reserved.
//

import Foundation
import CoreData


open class Episode: NSManagedObject {
    static let entityName = "Episode"
    
    public convenience init(context: NSManagedObjectContext?, entityDescription: NSEntityDescription, sharedPath: String) {
        
        self.init(entity: entityDescription, insertInto: context)
        self.sharedURLString = sharedPath
        self.isSynced = false
    
    }
    
    open static func entityDescription(_ context: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: Episode.entityName, in: context)
    }
    
    open static func allSyncedEpisodes(_ context: NSManagedObjectContext) -> [Episode] {
        return self.allEpisodes(context, predicate: NSPredicate(format: "isSynced = true"))
    }
    
    open static func allUnsyncedEpisodes(_ context: NSManagedObjectContext) -> [Episode] {
        return self.allEpisodes(context, predicate: NSPredicate(format: "isSynced = false"))
    }
    
    open func fileURL() -> URL? {
        if let fileURLString = self.fileURLString {
            return URL(string: fileURLString)
        }
        return nil
    }
    
    open func metadata() -> [String: AnyObject]? {
        if let title = self.title {
            return [
                "title": title as AnyObject
            ]
        }
        return nil
    }
    
    fileprivate static func allEpisodes(_ context: NSManagedObjectContext, predicate: NSPredicate) -> [Episode] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        fetchRequest.entity = Episode.entityDescription(context)
        
        fetchRequest.predicate = predicate
        do {
            if let results = try context.fetch(fetchRequest) as? [Episode] {
                return results
            }
        } catch {
            print("error in fetching episodes: \(error)")
        }
        return []

    }
}
