//
//  InterfaceController.swift
//  Podcasts Extension
//
//  Created by Samantha John on 12/25/15.
//  Copyright © 2015 SamanthaJohn. All rights reserved.
//

import WatchKit
import Foundation

class PlayerInterfaceController: WKInterfaceController {
    let watchSync = WatchSync()
    var player: WKAudioFilePlayer?
    var playerItem: WKAudioFilePlayerItem?
    var isPlaying = false
    var timer: Timer?
    
    @IBOutlet weak var timeElapsedLabel: WKInterfaceLabel?
    @IBOutlet weak var nameLabel: WKInterfaceLabel?
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
            case .readyToPlay:
                player.play()
                self.isPlaying = true
                self.playButton?.setTitle("Pause")
                self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(PlayerInterfaceController.playing(_:)), userInfo: nil, repeats: true)
            case .failed:
                print("failed")
            case .unknown:
                print("unknown")
            }
        }
    }
    
    func playing(_ timer: Timer) {
        if let playerItem = self.playerItem,
            let label = self.timeElapsedLabel {
                label.setText("Time: \(playerItem.currentTime)")
                switch(playerItem.status) {
                case .readyToPlay:
                    print("player item ready to play")
                case .failed:
                    print("player item failed: \(playerItem.error)")
                case .unknown:
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

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        let fileManager = FileManager.default
   
        if let containerURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.PodcastWatch")
        {
            
            let fileURL = containerURL.appendingPathComponent("media.mp3")
            let fileCoordinator = NSFileCoordinator()
            
            fileCoordinator.coordinate(readingItemAt: fileURL, options: .withoutChanges, error: nil, byAccessor: { (url) -> Void in
                let path = url.path
                let exists = fileManager.fileExists(atPath: path)
                print("exists: \(exists), path: \(path)")
                let audioAsset = WKAudioFileAsset(url: url)
                let playerItem = WKAudioFilePlayerItem(asset: audioAsset)
                self.playerItem = playerItem
                self.nameLabel?.setText(audioAsset.title)
                self.player = WKAudioFilePlayer(playerItem: playerItem)
            })
            
            NotificationCenter.default.addObserver(self, selector: #selector(PlayerInterfaceController.stopTimer), name: NSNotification.Name.WKAudioFilePlayerItemDidPlayToEndTime, object: nil)
           
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

//
//  WatchSync.swift
//  PodcastWatch
//
//  Created by Samantha John on 12/26/15.
//  Copyright © 2015 SamanthaJohn. All rights reserved.
//

import UIKit
import WatchConnectivity

class WatchSync: NSObject, WCSessionDelegate {
    
    /** Called when the session has completed activation. If session state is WCSessionActivationStateNotActivated there will be an error with more details. */
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    
    let session: WCSession?
    
    override init() {
        
        if WCSession.isSupported() {
            let session = WCSession.default()
            self.session = session
        } else {
            self.session = nil
        }
        
        super.init()
        
        self.session?.delegate = self
        self.session?.activate()
        
    }
    
    func session(_ session: WCSession, didFinish fileTransfer: WCSessionFileTransfer, error: Error?) {
        if (error != nil) {
            print("error: \(error)")
        } else {
            print("success")
        }
        
    }
    
    func session(_ session: WCSession, didReceive file: WCSessionFile) {
        let tmpFilePath = file.fileURL.path
        if let mediaFilePath = self.mediaFilePath {
            let fileManager = FileManager.default
            do {
                try fileManager.copyItem(atPath: tmpFilePath, toPath: mediaFilePath)
            } catch {
                print("error: \(error)")
            }
        }
    }
    
    lazy var mediaFilePath: String? = {
        let fileManager = FileManager.default
        if let containerURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.PodcastWatch") {
            return containerURL.appendingPathComponent("media.mp3").path
        }
        
        return nil
    }()
    
    func writeToFile(_ data: Data, metadata: [String: AnyObject]?) {
        if let filePath = self.mediaFilePath {
            
            let fileManager = FileManager.default
            let success = fileManager.createFile(atPath: filePath, contents: data, attributes: nil)
            
            if (success == true) {
                let url = URL(fileURLWithPath: filePath)
                let transfer = session?.transferFile(url, metadata: metadata)
                print("transferring: \(transfer?.isTransferring)")
            }
        }
    }
}
