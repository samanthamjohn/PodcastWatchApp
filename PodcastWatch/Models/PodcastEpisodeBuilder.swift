//
//  PodcastEpisodeDownloader.swift
//  PodcastWatch
//
//  Created by Samantha John on 12/25/15.
//  Copyright © 2015 SamanthaJohn. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import PodcastWatchModels

class PodcastEpisodeDownloader: NSObject {
    
    func downloadEpisodeData(episode: Episode) {
        
        let manager = AFHTTPSessionManager()
        if let path = episode.sharedURLString {
            manager.GET(path, parameters: nil, progress: { (progress) -> Void in
                
                print("progress: \(progress)")
                
                }, success: { (task, responseObject) -> Void in
                    if let responseObject = responseObject {
                        print("json response: \(responseObject)")
                        self.populateEpisodeFromResponse(episode, responseObject: responseObject)
                    }
                    
                }) { (operation, error) -> Void in
                    
                    print("Error: \(error)")
            }
        }

    }
    
    func populateEpisodeFromResponse(episode: Episode, responseObject: AnyObject) {
//        if let episode = NSEntityDescription.insertNewObjectForEntityForName("Episode", inManagedObjectContext: context) as? Episode {
//            
//            episode.title = "FOO"
//            
//            do {
//                try context.save()
//            } catch {
//                fatalError("Failure to save context: \(error)")
//            }
//
//        }

    }
    
    
}
