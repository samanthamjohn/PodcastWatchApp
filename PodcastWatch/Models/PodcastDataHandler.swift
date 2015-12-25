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
    override init() {
        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            self.dataController = appDelegate.dataController
        }
        super.init()
        
        // build a fake episode
        if let dataController = self.dataController,
            let desc = Episode.entityDescription(dataController.managedObjectContext)  {
            _ = Episode(context: dataController.managedObjectContext, entityDescription: desc, sharedPath: "foo")
                dataController.saveContext()
        }
    }
    
    func fetchEpisodes() -> [Episode] {

        if let dataController = self.dataController {
            return Episode.allUnsyncedEpisodes(dataController.managedObjectContext)
        }

        
        return []
    }
    
    
}
