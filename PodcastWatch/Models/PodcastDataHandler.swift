//
//  PodcastData.swift
//  PodcastWatch
//
//  Created by Samantha John on 12/24/15.
//  Copyright © 2015 SamanthaJohn. All rights reserved.
//

import UIKit
import PodcastWatchModels

class PodcastDataHandler: NSObject {
    var dataController: DataController?
    let downloader = PodcastEpisodeDownloader()
    override init() {
        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            let dataController = appDelegate.dataController
            self.dataController = dataController
            downloader.downloadUnsyncedEpisodeData(dataController.managedObjectContext)
        }
        super.init()
    }
    
    
    func fetchEpisodes() -> [Episode] {

        if let dataController = self.dataController {
            return Episode.allSyncedEpisodes(dataController.managedObjectContext)
        }

        return []
    }
    
    
}
