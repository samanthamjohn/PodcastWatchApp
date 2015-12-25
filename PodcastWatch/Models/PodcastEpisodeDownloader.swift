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

    func downloadUnsyncedEpisodeData(context: NSManagedObjectContext) {
        Episode.allUnsyncedEpisodes(context).forEach { (episode) -> () in
            self.downloadEpisodeData(episode)
        }
    }
    
    func downloadEpisodeData(episode: Episode) {
        
        let manager = AFHTTPSessionManager()
        let responseSerializer = AFCompoundResponseSerializer()
        
        responseSerializer.acceptableContentTypes = NSSet(object: "text/html") as! Set<String>

        manager.responseSerializer = responseSerializer
        if let path = episode.sharedURLString {
            manager.GET(path, parameters: nil, progress: { (progress) -> Void in
                
                print("progress: \(progress)")
                
                }, success: { (task, responseObject) -> Void in
                    if let responseObject = responseObject {
                        self.populateEpisodeFromResponse(episode, responseObject: responseObject)
                    }
                    
                }) { (operation, error) -> Void in
                    
                    print("Error: \(error)")
            }
        }

    }
    
    func populateEpisodeFromResponse(episode: Episode, responseObject: AnyObject) {
        if let data = responseObject as? NSData {
            do {
                let node = try IGHTMLDocument(HTMLData: data, encoding: nil)
                let audioSourceNode = node.queryWithCSS("audio source").firstObject()
                episode.fileURLString = audioSourceNode.attribute("src")

                let titleNode = node.queryWithCSS(".title").firstObject()
                episode.title = titleNode.innerHtml()
                
                let imageURLNode = node.queryWithCSS("img.art.fullart").firstObject()
                episode.imageURLString = imageURLNode.attribute("src")
                
                episode.isSynced = true
                
                if let delegate = UIApplication.sharedApplication().delegate as? AppDelegate {
                    delegate.dataController.saveContext()
                }

            } catch {
                print("html parse error: \(error)")
            }
        }

    }
    
    
}
