//
//  PodcastData.swift
//  PodcastWatch
//
//  Created by Samantha John on 12/24/15.
//  Copyright © 2015 SamanthaJohn. All rights reserved.
//

import UIKit

enum PodcastType: String {
    case ITunes, Overcast
}

let defaultsSuiteName = "group.PodcastWatch"
let podcastsKey = "podcasts"
let pathKey = "path"
let typeKey = "type"

public class PodcastDataHandler: NSObject {
    
    
    public lazy var podcasts: [Podcast] = {
        var podcasts: [Podcast] = []
        if  let defaults = self.defaults,
            let podcastData = defaults.objectForKey(podcastsKey) as? [[String: AnyObject]] {
                
                podcastData.forEach { (datum) -> () in
                    if  let path = datum[pathKey] as? String,
                        let url = NSURL(string: path),
                        let typeStr = datum[typeKey] as? String,
                        let type = PodcastType(rawValue: typeStr)
                    {
                        let podcast = Podcast(url: url, type: type)
                        podcasts.append(podcast)
                    }
                    
                }
        }
        
        return podcasts
    }()
    
    
    lazy var defaults: NSUserDefaults? =  {
        return NSUserDefaults(suiteName: defaultsSuiteName)
    }()
    
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
                    self.syncUserDefaults(path: url.absoluteString, type: .Overcast)
                }
                
                if let string = coding as? String {
                    if let url = self.getiTunesPodcastIDFromString(string) {
                        self.syncUserDefaults(path: url.absoluteString, type: .ITunes)
                    }
                }
            }
        }
        
    }
    
    func syncUserDefaults(path path: String, type: PodcastType) {
        print(path)
        if let defaults = self.defaults {
            var podcasts: [[String: String]] = []
            if let existingPodcasts = defaults.objectForKey(podcastsKey) as? [[String: String]] {
                podcasts = existingPodcasts
            }

            podcasts.append([pathKey : path, typeKey : type.rawValue])
            defaults.setObject(podcasts, forKey: podcastsKey)
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
