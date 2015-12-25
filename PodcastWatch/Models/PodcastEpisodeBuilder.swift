//
//  PodcastEpisodeBuilder.swift
//  PodcastWatch
//
//  Created by Samantha John on 12/25/15.
//  Copyright © 2015 SamanthaJohn. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class PodcastEpisodeBuilder: NSObject {
    let dataController = DataController()
    
    func buildEpisode(path: String, completion: (success: Bool, error: NSError?) -> Void) {
        
        let manager = AFHTTPSessionManager()
        
        manager.GET(path, parameters: nil, progress: { (progress) -> Void in
            
                print("progress: \(progress)")
            
            }, success: { (task, responseObject) -> Void in
                if let responseObject = responseObject {
                    print("json response: \(responseObject)")
                    self.buildEpisodeFromResponse(responseObject, completion: completion)
                }
                
            }) { (operation, error) -> Void in
                
                print("Error: \(error)")
                completion(success: false, error: error)
        }
    }
    
    func buildEpisodeFromResponse(responseObject: AnyObject, completion: (success: Bool, error: NSError?) -> Void) {
        let context = dataController.managedObjectContext
        if let episode = NSEntityDescription.insertNewObjectForEntityForName("Episode", inManagedObjectContext: context) as? Episode {
            
            episode.title = "FOO"
            
            do {
                try context.save()
                completion(success: true, error: nil)
            } catch {
                completion(success: false, error: nil)
                fatalError("Failure to save context: \(error)")
            }
        }

    }
    
    
}
