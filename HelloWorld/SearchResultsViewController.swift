//
//  ViewController.swift
//  HelloWorld
//
//  Created by Connor Goddard on 27/11/2014.
//  Copyright (c) 2014 Connor Goddard. All rights reserved.
//

import UIKit

class SearchResultsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, APIControllerProtocol {
    
    var api = APIController();

    @IBOutlet weak var appsTableView: UITableView!
    
    var tableData = []
    
    
    func didReceiveAPIResults(results: NSDictionary) {
        
        var resultsArr: NSArray = results["results"] as NSArray
        
        dispatch_async(dispatch_get_main_queue(), {
            self.tableData = resultsArr
            self.appsTableView!.reloadData()
        })
        
    }
    
    // CG - Simply return the number of resultant objects from the UITableView data store.
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    // CG - Render each of the UITableView cells.
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "MyTestCell")
        
        // CG - Get the data for this particular cell using the 'indexPath.row' index.
        let rowData: NSDictionary = self.tableData[indexPath.row] as NSDictionary
        
        // CG - cell.textLabel CANNOT be nil, therefore it is not optional. We need to downcast the 'rowData' object to tell Swift to force it to unwrap the value.
        cell.textLabel.text = rowData["trackName"] as? String
        
        // Grab the artworkUrl60 key to get an image URL for the app's thumbnail
        let urlString: NSString = rowData["artworkUrl60"] as NSString
        let imgURL: NSURL? = NSURL(string: urlString)
        
        // Download an NSData representation of the image at the URL
        let imgData = NSData(contentsOfURL: imgURL!)
        cell.imageView.image = UIImage(data: imgData!)
        
        // Get the formatted price string for display in the subtitle
        
        println(rowData["trackPrice"] as Double);
        
        // CG - We need to cast the 'rowData["trackPrice"]' to a Double, before converting it to a NSString.
        // CG - Use the optional form of the type cast operator (as?) when you are not sure if the downcast will succeed. This form of the operator will always return an optional value, and the value will be nil if the downcast was not possible. This enables you to check for a successful downcast.
        let formattedPrice: NSString = NSString(format: "£%.2f", rowData["trackPrice"] as Double)
        
        // CG - Alternative method to do the same as above.
        
        // let test = rowData["trackPrice"];
        // let formattedPrice: NSString = "\(test)"
        
        
        // CG - Example of OPTIONAL CHAINING (e.g. if 'detailTextLabel' exists, access its 'text' property)
        cell.detailTextLabel?.text = formattedPrice
        
        return cell
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // CG - Set the delegate of the 'APIController' object to this class so that we can call the 'didReceiveAPIResults' method from the 'APIController'.
        self.api.delegate = self;
        
        api.searchItunesFor("Avicii")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

