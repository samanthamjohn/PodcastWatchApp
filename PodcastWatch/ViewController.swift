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
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: self.cellIdentifier)
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.doneDownloading), name: NSNotification.Name(rawValue: episodesDownloaded), object: nil)
        
    }
    
    func doneDownloading() {
        self.episodes = self.dataHandler.fetchEpisodes()
        self.tableView.reloadData()
    }
    
    // MARK: - UITableViewDataSoure
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.episodes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) {

            cell.textLabel?.text = self.episodes[indexPath.row].title

            return cell
        } else {

        }
        
        return UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel(frame: CGRect.zero)
        label.text = NSLocalizedString("Podcasts", comment: "")
        label.textAlignment = .center
        return label
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 100
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let podcast = self.episodes[indexPath.row]
        let downloader = PodcastEpisodeDownloader()
        downloader.watchSync = self.watchSync
        let cell = tableView.cellForRow(at: indexPath)
        cell?.textLabel?.text = "Begin Downloading"
        downloader.downloadEpisodeMp3(podcast) { (progressPercent) -> Void in
            
            DispatchQueue.main.async(execute: {
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
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.tableView.frame = self.view.bounds
    }

}

