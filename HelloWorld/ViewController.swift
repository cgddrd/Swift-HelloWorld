//
//  ViewController.swift
//  HelloWorld
//
//  Created by Connor Goddard on 27/11/2014.
//  Copyright (c) 2014 Connor Goddard. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var appsTableView: UITableView!
    
    var tableData = []
    
    func searchItunesFor(searchTerm: String) {
        
        // The iTunes API wants multiple terms separated by + symbols, so replace spaces with + signs
        let itunesSearchTerm = searchTerm.stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
        
        // Now escape anything else that isn't URL-friendly
        if let escapedSearchTerm = itunesSearchTerm.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding) {
        
            //let urlPath = "http://itunes.apple.com/search?term=\(escapedSearchTerm)&media=software"
            
            // CG - Search for music instead.
            let urlPath = "https://itunes.apple.com/search?term=\(escapedSearchTerm)&media=music"
            let url = NSURL(string: urlPath)
            
            // CG - Grab the default NSURLSession object. This is used for all our networking calls.
            let session = NSURLSession.sharedSession()
            
            /* 
                CG - creates the connection task which is going to be used to actually send the request.

                'dataTaskWithURL' has a closure as it’s last parameter, which gets run upon completion of the request. ('completionHandler')
            
                Here we check for errors in the response, then parse the JSON, and call the delegate method didReceiveAPIResults

            */
            let task = session.dataTaskWithURL(url!, completionHandler: {data, response, error -> Void in
                
                println("Task completed")
                
                if(error != nil) {
                    // If there is an error in the web request, print it to the console
                    println(error.localizedDescription)
                }
                
                // CG - Create new NSError object that is optional (i.e. may or may not contain a value)
                var err: NSError?
                
                // CG - Parse the returned JSON response (data), passing in the 'err' variable created above.
                var jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as NSDictionary
                
                // CG - Deal with any errors resulting from the JSON parsing.
                if(err != nil) {
                    // If there is an error parsing JSON, print it to the console
                    println("JSON Error \(err!.localizedDescription)")
                }
                
                //Get the 'results' array from the JSON file.
                let results: NSArray = jsonResult["results"] as NSArray
                
                
                // CG - Once we have got the response, parsed it and called 'didReceiveAPIResults' then we need to move back to the 'main' thread so we can update the UI.
                dispatch_async(dispatch_get_main_queue(), {
                    
                    // CG - Pass in the results, before reloading the table view to reflect the changes. (Calls the UITableView delegate functions)
                    self.tableData = results
                    self.appsTableView!.reloadData()
                })
                
            })
            
            // CG - Begin the actual asynchronous request.
            task.resume()
        }
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
        
        // CG - Conduct search for music artist.
        searchItunesFor("Avicii")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

