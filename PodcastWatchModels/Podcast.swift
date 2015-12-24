//
//  Podcast.swift
//  PodcastWatch
//
//  Created by Samantha John on 12/24/15.
//  Copyright © 2015 SamanthaJohn. All rights reserved.
//

import UIKit

public class Podcast: NSObject {
    let url: NSURL
    let type: PodcastType
    
    init(url: NSURL, type: PodcastType) {
        self.url = url
        self.type = type
        super.init()
        
    }
    
}
