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
    
    override init() {
        super.init()
        self.buildEpisodes()
    }
        
    private lazy var defaults: NSUserDefaults? =  {
        return NSUserDefaults(suiteName:  defaultsSuiteName)
    }()
    
    private func buildEpisodes() {
        let episodeBuilder = PodcastEpisodeBuilder()
        
        if let defaults = self.defaults,
            let podcastData = defaults.objectForKey(podcastURLSKey) as? [String: [String]],
            let episodeData = podcastData[PodcastType.Overcast.rawValue]
        {

            episodeData.forEach{ (path) -> () in
                episodeBuilder.buildEpisode(path) { (success, error) in
                    if (success) {
                        self.removeEpisodeAtPath(path)
                    }
                }
            }
        }
        
    }
    
    private func removeEpisodeAtPath(path: String){
        if let defaults = self.defaults,
            var podcastData = defaults.objectForKey(podcastURLSKey) as? [String: [String]],
            var episodeData = podcastData[PodcastType.Overcast.rawValue]
        {
            if let index = episodeData.indexOf(path) {
                episodeData.removeAtIndex(index)
                podcastData[PodcastType.Overcast.rawValue] = episodeData
                defaults.setObject(podcastData, forKey: podcastURLSKey)
            }
        }
    }
}
