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
    let session: WCSession?
    
    override init() {
        
        if WCSession.isSupported() {
            let session = WCSession.defaultSession()
            self.session = session
        } else {
            self.session = nil
        }
        
        super.init()
        
        self.session?.delegate = self
        self.session?.activateSession()
        
    }
    
    func session(session: WCSession, didFinishFileTransfer fileTransfer: WCSessionFileTransfer, error: NSError?) {
        if (error != nil) {
            print("error: \(error)")
        } else {
            print("success")
        }
        
    }
    
    func session(session: WCSession, didReceiveFile file: WCSessionFile) {
        if let mediaFilePath = self.mediaFilePath,
        let tmpFilePath = file.fileURL.path {
            let fileManager = NSFileManager.defaultManager()
            do {
                try fileManager.copyItemAtPath(tmpFilePath, toPath: mediaFilePath)
            } catch {
                print("error: \(error)")
            }
        }
    }
    
    lazy var mediaFilePath: String? = {
        let fileManager = NSFileManager.defaultManager()
        if let containerURL = fileManager.containerURLForSecurityApplicationGroupIdentifier("group.PodcastWatch") {
            return containerURL.URLByAppendingPathComponent("media.mp3").path
        }
        
        return nil
    }()
    
    func writeToFile(data: NSData) {
        if let filePath = self.mediaFilePath {
            
            let fileManager = NSFileManager.defaultManager()
            let success = fileManager.createFileAtPath(filePath, contents: data, attributes: nil)
            
                if (success == true) {
                    let url = NSURL(fileURLWithPath: filePath)
                    let transfer = session?.transferFile(url, metadata: nil)
                    print("transferring: \(transfer?.transferring)")
                }
        }
    }
}
