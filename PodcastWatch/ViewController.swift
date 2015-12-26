//
//  ViewController.swift
//  PodcastWatch
//
//  Created by Samantha John on 12/24/15.
//  Copyright © 2015 SamanthaJohn. All rights reserved.
//

import UIKit
import PodcastWatchModels
let episodesDownloaded = "episodesDownloaded"
class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let tableView = UITableView()
    let cellIdentifier = "cellIdentifier"
    var episodes: [Episode] = []
    let dataHandler = PodcastDataHandler()
    let watchSync = WatchSync()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.episodes = self.dataHandler.fetchEpisodes()
        self.view.addSubview(self.tableView)
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: self.cellIdentifier)
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "doneDownloading", name: episodesDownloaded, object: nil)
        
    }
    
    func doneDownloading() {
        self.episodes = self.dataHandler.fetchEpisodes()
        self.tableView.reloadData()
    }
    
    // MARK: - UITableViewDataSoure
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.episodes.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) {

            cell.textLabel?.text = self.episodes[indexPath.row].title

            return cell
        } else {

        }
        
        return UITableViewCell(style: .Subtitle, reuseIdentifier: cellIdentifier)
        
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel(frame: CGRect.zero)
        label.text = NSLocalizedString("Podcasts", comment: "")
        label.textAlignment = .Center
        return label
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 100
    }
    
    // MARK: - UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let podcast = self.episodes[indexPath.row]
        let downloader = PodcastEpisodeDownloader()
        downloader.watchSync = self.watchSync
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        cell?.textLabel?.text = "Begin Downloading"
        downloader.downloadEpisodeMp3(podcast) { (progressPercent) -> Void in
            
            dispatch_async(dispatch_get_main_queue(), {
                if (progressPercent == 1) {
                    if let title = podcast.title {
                        cell?.textLabel?.text = "Downloaded \(title)"
                    }
                    
                } else {
                    let progressText = "\(Int(progressPercent * 100))% Done"
                    cell?.textLabel?.text = progressText
                }
            });

            
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.tableView.frame = self.view.bounds
    }

}

