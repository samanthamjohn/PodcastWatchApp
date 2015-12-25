//
//  ActionRequestHandler.swift
//  WatchSync
//
//  Created by Samantha John on 12/24/15.
//  Copyright © 2015 SamanthaJohn. All rights reserved.
//

import UIKit
import MobileCoreServices
import PodcastWatchModels

class ActionRequestHandler: NSObject, NSExtensionRequestHandling {

    var extensionContext: NSExtensionContext?
    
    func beginRequestWithExtensionContext(context: NSExtensionContext) {
    
        self.extensionContext = context
        
        let dataHandler = ExtensionDataHandler()
        context.inputItems.forEach { (input) -> () in
            dataHandler.syncExtensionItem(input)
        }
        
    }
}
