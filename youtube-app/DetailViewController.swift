//
//  DetailViewController.swift
//  youtube-app
//
//  Created by Nhat Ton on 13/2/18.
//  Copyright © 2018 Nhat Ton. All rights reserved.
//

import UIKit
import youtube_ios_player_helper

class DetailViewController: UIViewController {

    @IBOutlet var playerView: YTPlayerView!

    func configureView() {
        // Update the user interface for the detail item.
        if let detail = detailItem {
            if let player = playerView {
                player.load(withVideoId: detail)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var detailItem: String? {
        didSet {
            // Update the view.
            configureView()
        }
    }


}

