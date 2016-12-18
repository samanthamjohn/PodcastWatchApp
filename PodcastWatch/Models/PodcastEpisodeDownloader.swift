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
    
    func downloadUnsyncedEpisodeData(_ context: NSManagedObjectContext) {
        Episode.allUnsyncedEpisodes(context).forEach { (episode) -> () in
            NotificationCenter.default.post(name: Notification.Name(rawValue: beginDownloadingNotification), object: nil)
            self.downloadEpisodeData(episode)
        }
    }
    
    func downloadEpisodeMp3(_ episode: Episode, progressCallback: @escaping (_ progressPercent: Double) -> Void) {

        if let fileURLString = episode.fileURLString
        {
            let manager = AFHTTPSessionManager()
            
            let contentType = "audio/mpeg"
            let responseSerializer = AFCompoundResponseSerializer()
            
            responseSerializer.acceptableContentTypes = NSSet(object: contentType) as? Set<String>
            
            manager.responseSerializer = responseSerializer
            
            
            manager.get(fileURLString, parameters: nil, progress: { (progress) -> Void in
                
                    progressCallback(progress.fractionCompleted)
                
                }, success: { (task, responseObject) -> Void in
                    if let responseObject = responseObject as? Data,
                    let watchSync = self.watchSync
                    {
                        watchSync.writeToFile(responseObject, metadata: episode.metadata())
                    }
                    
                }) { (operation, error) -> Void in
                    
                    print("Error: \(error)")
            }
        }
        
    }
    
    func downloadEpisodeData(_ episode: Episode) {
        
        let manager = AFHTTPSessionManager()
        let responseSerializer = AFCompoundResponseSerializer()
        
        responseSerializer.acceptableContentTypes = NSSet(object: "text/html") as? Set<String>

        manager.responseSerializer = responseSerializer
        if let path = episode.sharedURLString {
            manager.get(path, parameters: nil, progress: { (progress) -> Void in
                
                print("progress: \(progress)")
                
                }, success: { (task, responseObject) -> Void in
                    if let responseObject = responseObject {
                        self.populateEpisodeFromResponse(episode, responseObject: responseObject as AnyObject)
                    }
                    
                }) { (operation, error) -> Void in
                    
                    print("Error: \(error)")
            }
        }

    }
    
    func populateEpisodeFromResponse(_ episode: Episode, responseObject: AnyObject) {
        if let data = responseObject as? Data {
            do {
                let node = try IGHTMLDocument(htmlData: data, encoding: nil)
                let audioSourceNode = node.query(withCSS: "audio source").firstObject()
                episode.fileURLString = audioSourceNode?.attribute("src")

                let titleNode = node.query(withCSS: ".title").firstObject()
                episode.title = titleNode?.innerHtml()
                
                let imageURLNode = node.query(withCSS: "img.art.fullart").firstObject()
                episode.imageURLString = imageURLNode?.attribute("src")
                
                episode.isSynced = true
                
                if let delegate = UIApplication.shared.delegate as? AppDelegate {
                    delegate.dataController.saveContext()
                }
                
                NotificationCenter.default.post(name: Notification.Name(rawValue: episodesDownloaded), object: nil)

            } catch {
                print("html parse error: \(error)")
            }
        }

    }
    
    
}
