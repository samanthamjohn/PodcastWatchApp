//
//  ExtensionDataHandler.swift
//  PodcastWatch
//
//  Created by Samantha John on 12/25/15.
//  Copyright © 2015 SamanthaJohn. All rights reserved.
//

import UIKit
public let defaultsSuiteName = "group.PodcastWatch"
public let podcastURLSKey = "podcastsURLS"
public let episodesKey = "episodes"

public enum PodcastType: String {
    case ITunes, Overcast
}

public class ExtensionDataHandler: NSObject {

    
    let defaults: NSUserDefaults? = NSUserDefaults(suiteName: defaultsSuiteName)
    
    public func syncExtensionItem(input: AnyObject) {
        if let attachments = input.attachments
        {
            attachments?.forEach { (item) -> () in
                self.syncItem(item)
            }
            
        }
    }
    
    private func syncItem(item: AnyObject) {
        if  let itemProvider = item as? NSItemProvider,
            let type = itemProvider.registeredTypeIdentifiers[0] as? String
        {
            itemProvider.loadItemForTypeIdentifier(type, options: nil) { (coding, error) -> Void in
                if let url = coding as? NSURL {
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
    
    func syncPathAndType(path path: String, type: PodcastType) {
        print(path)
        if let defaults = self.defaults {
            var podcasts: [String: [String]] = [PodcastType.Overcast.rawValue: [], PodcastType.ITunes.rawValue : []]
            if let existingPodcasts = defaults.objectForKey(podcastURLSKey) as? [String: [String]],
                var list = existingPodcasts[type.rawValue] {
                    
                    
                    list.append(path)
                    podcasts = existingPodcasts
                    podcasts[type.rawValue] = list
                    
            } else {
                podcasts[type.rawValue] = [path]
            }
            
            defaults.setObject(podcasts, forKey: podcastURLSKey)
            defaults.synchronize()
            
        }
    }
    
    func getiTunesURLFromSharedString(str: String) -> NSURL? {
        var itunesURL: NSURL?
        let pattern = "(?i)https?://(?:www\\.)?\\S+(?:/|\\b)"
        
        let nsstr = NSString(string: str)
        let all = NSRange(location: 0, length: nsstr.length)
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: NSRegularExpressionOptions(rawValue: 0))
            
            regex.enumerateMatchesInString(str, options: NSMatchingOptions(rawValue: 0), range: all) { (result, _, _) -> Void in
                if let res = result {
                    let path = nsstr.substringWithRange(res.range)
                    let url = NSURL(string: path)
                    if var idStr = url?.lastPathComponent {
                        let range = idStr.startIndex..<idStr.startIndex.advancedBy(2)
                        idStr.removeRange(range)
                        itunesURL = NSURL(string: "https://itunes.apple.com/lookup?id=\(idStr)&entity=podcast")
                    }
                }
                
            }
        } catch {
        }
        return itunesURL
    }
    
}
