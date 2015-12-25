//
//  Episode+CoreDataProperties.swift
//  PodcastWatch
//
//  Created by Samantha John on 12/25/15.
//  Copyright © 2015 SamanthaJohn. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

public extension Episode {

    @NSManaged var title: String?
    @NSManaged var fileURLString: String?
    @NSManaged var imageURLString: String?
    @NSManaged var episodeDescription: String?
    @NSManaged public var sharedURLString: String?
    @NSManaged var isSynced: Bool

}
