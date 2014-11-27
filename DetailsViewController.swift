//
//  DetailsViewController.swift
//  HelloWorld
//
//  Created by Connor Goddard on 27/11/2014.
//  Copyright (c) 2014 Connor Goddard. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController {
    
    @IBOutlet weak var albumCover: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    // CG - Contains the currently selected album (set by the 'prepareForSegue' method in the 'SearchResultsController')
    var album: Album?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = self.album?.title
        albumCover.image = UIImage(data: NSData(contentsOfURL: NSURL(string: self.album!.largeImageURL)!)!)
    }
}
