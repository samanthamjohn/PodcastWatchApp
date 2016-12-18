//
//  ExtensionDataHandler.swift
//  PodcastWatch
//
//  Created by Samantha John on 12/25/15.
//  Copyright © 2015 SamanthaJohn. All rights reserved.
//

import UIKit
import CoreData


public enum PodcastType: String {
    case ITunes, Overcast
}

open class ExtensionDataHandler: NSObject {
    
    let dataController = DataController()

    open func syncExtensionItem(_ input: AnyObject) {
        if let attachments = input.attachments
        {
            attachments?.forEach { (item) -> () in
                self.syncItem(item as AnyObject)
            }
            
        }
    }
    
    fileprivate func syncItem(_ item: AnyObject) {
        if  let itemProvider = item as? NSItemProvider,
            let type = itemProvider.registeredTypeIdentifiers[0] as? String
        {
            itemProvider.loadItem(forTypeIdentifier: type, options: nil) { (coding, error) -> Void in
                if let url = coding as? URL {
                    self.syncPathAndType(path: url.absoluteString, type: .Overcast)
                }
                
                if let string = coding as? String {
                    if let url = self.getiTunesURLFromSharedString(string) {
                        self.syncPathAndType(path: url.absoluteString, type: .ITunes)
                    }
                }
            }
        }
        
    }
    
    fileprivate func syncPathAndType(path: String, type: PodcastType) {
        
        if (type == .Overcast) {
            let context = self.dataController.managedObjectContext
            if let entityDescription = Episode.entityDescription(context) {
                
                _ = Episode(context: context, entityDescription: entityDescription, sharedPath: path)
                
                do {
                    try context.save()
                } catch {
                    print("Error: \(error)")
                }
                
            }
            

        }

    }
    
    func getiTunesURLFromSharedString(_ str: String) -> URL? {
        var itunesURL: URL?
        let pattern = "(?i)https?://(?:www\\.)?\\S+(?:/|\\b)"
        
        let nsstr = NSString(string: str)
        let all = NSRange(location: 0, length: nsstr.length)
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options(rawValue: 0))
            
            regex.enumerateMatches(in: str, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: all) { (result, _, _) -> Void in
                if let res = result {
                    let path = nsstr.substring(with: res.range)
                    let url = URL(string: path)
                    if var idStr = url?.lastPathComponent {
                        let range = idStr.startIndex..<idStr.characters.index(idStr.startIndex, offsetBy: 2)
                        idStr.removeSubrange(range)
                        itunesURL = URL(string: "https://itunes.apple.com/lookup?id=\(idStr)&entity=podcast")
                    }
                }
                
            }
        } catch {
        }
        return itunesURL
    }
    
}
