//
//  InterfaceController.swift
//  Podcasts Extension
//
//  Created by Samantha John on 12/25/15.
//  Copyright © 2015 SamanthaJohn. All rights reserved.
//

import WatchKit
import Foundation

class InterfaceController: WKInterfaceController {
    let watchSync = WatchSync()
    var player: WKAudioFilePlayer?
    var playerItem: WKAudioFilePlayerItem?
    var isPlaying = false
    var timer: NSTimer?
    
    @IBOutlet weak var timeElapsedLabel: WKInterfaceLabel?
    @IBOutlet weak var playButton: WKInterfaceButton?
    
    @IBAction func playBtnTapped() {
        
        if let player = self.player {
            
            if self.isPlaying {
                self.playButton?.setTitle("Play")
                self.isPlaying = false
                player.pause()
                self.timeElapsedLabel?.setText("")
                return
            }
            
            switch player.status {
            case .ReadyToPlay:
                player.play()
                self.isPlaying = true
                self.playButton?.setTitle("Pause")
                self.timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "playing:", userInfo: nil, repeats: true)
            case .Failed:
                print("failed")
            case .Unknown:
                print("unknown")
            }
        }
    }
    
    func playing(timer: NSTimer) {
        if let playerItem = self.playerItem,
            let label = self.timeElapsedLabel {
                label.setText("Time: \(playerItem.currentTime)")
                switch(playerItem.status) {
                case .ReadyToPlay:
                    print("player item ready to play")
                case .Failed:
                    print("player item failed: \(playerItem.error)")
                case .Unknown:
                    print("player item status unknown")
                }
                
        }
    }
    
    func stopTimer() {
        if let timer = self.timer {
            timer.invalidate()
            self.isPlaying = false
            self.timer = nil
        }
    }

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        let fileManager = NSFileManager.defaultManager()
   
        if let containerURL = fileManager.containerURLForSecurityApplicationGroupIdentifier("group.PodcastWatch")
        {
            
            let fileURL = containerURL.URLByAppendingPathComponent("media.mp3")
            let fileCoordinator = NSFileCoordinator()
            
            fileCoordinator.coordinateReadingItemAtURL(fileURL, options: .WithoutChanges, error: nil, byAccessor: { (url) -> Void in
                if let path = url.path {
                    let exists = fileManager.fileExistsAtPath(path)
                    print("exists: \(exists), path: \(path)")
                    
                }
                let audioAsset = WKAudioFileAsset(URL: url)
                let playerItem = WKAudioFilePlayerItem(asset: audioAsset)
                self.playerItem = playerItem
                self.player = WKAudioFilePlayer(playerItem: playerItem)

            })
            
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "stopTimer", name: WKAudioFilePlayerItemDidPlayToEndTimeNotification, object: nil)
           
        }
        
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
