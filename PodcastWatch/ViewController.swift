//
//  ViewController.swift
//  PodcastWatch
//
//  Created by Samantha John on 12/24/15.
//  Copyright © 2015 SamanthaJohn. All rights reserved.
//

import UIKit
import PodcastWatchModels

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let dataHandler = PodcastDataHandler()
        let podcasts = dataHandler.podcasts
        print(podcasts)
    }

}

