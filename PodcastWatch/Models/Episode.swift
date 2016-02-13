//
//  Episode.swift
//  PodcastWatch
//
//  Created by Samantha John on 12/25/15.
//  Copyright © 2015 SamanthaJohn. All rights reserved.
//

import Foundation
import CoreData


public class Episode: NSManagedObject {
    static let entityName = "Episode"
    
    public convenience init(context: NSManagedObjectContext?, entityDescription: NSEntityDescription, sharedPath: String) {
        
        self.init(entity: entityDescription, insertIntoManagedObjectContext: context)
        self.sharedURLString = sharedPath
        self.isSynced = false
    
    }
    
    public static func entityDescription(context: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entityForName(Episode.entityName, inManagedObjectContext: context)
    }
    
    public static func allSyncedEpisodes(context: NSManagedObjectContext) -> [Episode] {
        return self.allEpisodes(context, predicate: NSPredicate(format: "isSynced = true"))
    }
    
    public static func allUnsyncedEpisodes(context: NSManagedObjectContext) -> [Episode] {
        return self.allEpisodes(context, predicate: NSPredicate(format: "isSynced = false"))
    }
    
    public func fileURL() -> NSURL? {
        if let fileURLString = self.fileURLString {
            return NSURL(string: fileURLString)
        }
        return nil
    }
    
    public func metadata() -> [String: AnyObject]? {
        if let title = self.title {
            return [
                "title": title
            ]
        }
        return nil
    }
    
    private static func allEpisodes(context: NSManagedObjectContext, predicate: NSPredicate) -> [Episode] {
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = Episode.entityDescription(context)
        
        fetchRequest.predicate = predicate
        do {
            if let results = try context.executeFetchRequest(fetchRequest) as? [Episode] {
                return results
            }
        } catch {
            print("error in fetching episodes: \(error)")
        }
        return []

    }
}