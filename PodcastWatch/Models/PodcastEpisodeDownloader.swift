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

let beginDownloadingNotification = "beginDownloadingNotification"

class PodcastEpisodeDownloader: NSObject {
    
    var watchSync: WatchSync?
    
    func downloadUnsyncedEpisodeData(context: NSManagedObjectContext) {
        Episode.allUnsyncedEpisodes(context).forEach { (episode) -> () in
            NSNotificationCenter.defaultCenter().postNotificationName(beginDownloadingNotification, object: nil)
            self.downloadEpisodeData(episode)
        }
    }
    
    func downloadEpisodeMp3(episode: Episode, progressCallback: (progressPercent: Double) -> Void) {

        if let fileURLString = episode.fileURLString
        {
            let manager = AFHTTPSessionManager()
            
            let contentType = "audio/mpeg"
            let responseSerializer = AFCompoundResponseSerializer()
            
            responseSerializer.acceptableContentTypes = NSSet(object: contentType) as? Set<String>
            
            manager.responseSerializer = responseSerializer
            
            
            manager.GET(fileURLString, parameters: nil, progress: { (progress) -> Void in
                
                    progressCallback(progressPercent: progress.fractionCompleted)
                
                }, success: { (task, responseObject) -> Void in
                    if let responseObject = responseObject as? NSData,
                    let watchSync = self.watchSync
                    {
                        watchSync.writeToFile(responseObject)
                    }
                    
                }) { (operation, error) -> Void in
                    
                    print("Error: \(error)")
            }
        }
        
    }
    
    func downloadEpisodeData(episode: Episode) {
        
        let manager = AFHTTPSessionManager()
        let responseSerializer = AFCompoundResponseSerializer()
        
        responseSerializer.acceptableContentTypes = NSSet(object: "text/html") as? Set<String>

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
                
                NSNotificationCenter.defaultCenter().postNotificationName(episodesDownloaded, object: nil)

            } catch {
                print("html parse error: \(error)")
            }
        }

    }
    
    
}
