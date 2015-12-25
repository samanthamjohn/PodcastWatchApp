//
//  ViewController.swift
//  PodcastWatch
//
//  Created by Samantha John on 12/24/15.
//  Copyright © 2015 SamanthaJohn. All rights reserved.
//

import UIKit
import PodcastWatchModels

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let tableView = UITableView()
    let cellIdentifier = "cellIdentifier"
    var episodes: [Episode] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.episodes = []
        self.view.addSubview(self.tableView)
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: self.cellIdentifier)
        self.tableView.dataSource = self
        self.tableView.delegate = self
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
//            cell.textLabel?.text = self.episodes[indexPath.row].url.absoluteString
            return cell
        }
        
        return UITableViewCell(frame: CGRectZero)
        
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
//        UIApplication.sharedApplication().openURL(podcast.url)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.tableView.frame = self.view.bounds
    }

}

