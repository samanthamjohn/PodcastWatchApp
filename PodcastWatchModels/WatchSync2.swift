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
    /** Called when the session can no longer be used to modify or add any new transfers and, all interactive messages will be cancelled, but delegate callbacks for background transfers can still occur. This will happen when the selected watch is being changed. */
    @available(iOS 9.3, *)
    public func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }

    
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
        
        if let mediaFilePath = self.mediaFilePath,
            let tmpFilePath = file.fileURL?.path
            {
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
