//
//  PodcastsInterfaceController.swift
//  PodcastWatch
//
//  Created by Steve Ellis on 2/13/16.
//  Copyright © 2016 SamanthaJohn. All rights reserved.
//

import WatchKit
import Foundation


class PodcastsInterfaceController: WKInterfaceController {
    
    @IBOutlet weak var table: WKInterfaceTable!

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        table.setNumberOfRows(1, withRowType: "default")
        
        
        // Configure interface objects here.
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

class PodcastRowController: NSObject {
    @IBOutlet weak var titleLabel: WKInterfaceLabel?
    
    override init() {
        super.init()
        titleLabel?.setText("This American Life")
    }
    
}
