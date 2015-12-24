//
//  PodcastData.swift
//  PodcastWatch
//
//  Created by Samantha John on 12/24/15.
//  Copyright © 2015 SamanthaJohn. All rights reserved.
//

import UIKit

enum PodcastType {
    case ITunes, Overcast
}

public class PodcastDataHandler: NSObject {
    
    public func syncExtensionItem(input: AnyObject) {
        if let attachments = input.attachments
        {
            attachments?.forEach { (item) -> () in
                self.syncWithApp(item)
            }
            
        }
    }
    
    private func syncWithApp(item: AnyObject) {
        if  let itemProvider = item as? NSItemProvider,
            let type = itemProvider.registeredTypeIdentifiers[0] as? String
        {
            itemProvider.loadItemForTypeIdentifier(type, options: nil) { (coding, error) -> Void in
                if let url = coding as? NSURL {
                    self.syncUserDefaults(url, type: "overcast")
                }
                
                if let string = coding as? String {
                    if let url = self.getiTunesPodcastIDFromString(string) {
                        self.syncUserDefaults(url, type: "iTunes")
                    }
                }
            }
        }
        
    }
    
    func syncUserDefaults(url: NSURL, type: String) {
        print(url)
        if let defaults = NSUserDefaults(suiteName: "PodcastWatch"), var podcasts = defaults.objectForKey("podcasts") as? [[String: AnyObject]] {
            podcasts.append(["url" : url, "type" : type])
            defaults.setObject(podcasts, forKey: "podcasts")
            defaults.synchronize()
        }
    }
    
    func getiTunesPodcastIDFromString(str: String) -> NSURL? {
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
