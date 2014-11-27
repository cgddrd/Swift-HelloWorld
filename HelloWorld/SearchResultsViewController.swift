//
//  ViewController.swift
//  HelloWorld
//
//  Created by Connor Goddard on 27/11/2014.
//  Copyright (c) 2014 Connor Goddard. All rights reserved.
//

import UIKit

class SearchResultsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, APIControllerProtocol {
    
    // CG - Since the 'APIController' constructor now needs the delegate object to be instantiated before *it* can be instantiated itself, we need to make it an optional.
    //var api = APIController();
    
    var api : APIController?
    
    // CG - Dictionary of image cache. Key is a 'String' type (Image URL) and Value is a 'UIImage' type (Image data).
    
    // CG - Set Example: imageCache["Bob"] = UIImage(named: "Bob.jpg")
    
    // CG - Get Example: let imageOfBob = imageCache["Bob"]
    var imageCache = [String : UIImage]()
    
    // CG - Identifier for the reusable Prototype Cell created in the Storyboard.
    let kCellIdentifier: String = "SearchResultCell"
    
    @IBOutlet weak var appsTableView: UITableView!
    
    // CG - Create an array that contains strictly 'Album' objects.
    var albums = [Album]()
    
    
    // CG - Runs before the 'show' segue that moves from the 'SearchResultsController' view to the 'DetailsViewController' view. We are passing in the album info.
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        // CG - Get the destination controller from the segue 'destinationViewController' (which in this case is 'DetailsViewController') and cast it to that type.
        var detailsViewController: DetailsViewController = segue.destinationViewController as DetailsViewController
        
        // CG - Get the index of the currently selected album (via the UITableView cell)
        var albumIndex = appsTableView!.indexPathForSelectedRow()!.row
        
        //CG - Get the current album from the array (using the index just obtained)
        var selectedAlbum = self.albums[albumIndex]
        
        // CG - Set the 'album' variable of the destination controller ('DetailsViewController') to the currently selected album.
        detailsViewController.album = selectedAlbum
        
    }
    
    // CG - Called by the APIController once the data has been loaded asynchrounously.
    // The APIControllerProtocol method
    func didReceiveAPIResults(results: NSDictionary) {
        
        var resultsArr: NSArray = results["results"] as NSArray
        
        // CG - Return to the main thread in order to parse the JSON results and update the UI.
        dispatch_async(dispatch_get_main_queue(), {
            
            // Call STATIC method within 'Album' class to convert JSON into array of 'Album' objects.
            self.albums = Album.albumsWithJSON(resultsArr)
            
            self.appsTableView!.reloadData()
            
            // CG - Turn off the network indicator - networking is finished by this point.
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        })
    }
    
    // CG - Simply return the number of resultant objects from the UITableView data store.
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // CG - Update to return number of albums.
        return albums.count
    }
    
    // CG - Render each of the UITableView cells.
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier) as UITableViewCell
        
       // var rowData: NSDictionary = self.tableData[indexPath.row] as NSDictionary
        
        let album = self.albums[indexPath.row];
    
        cell.textLabel.text = album.title
        
        cell.imageView.image = UIImage(named: "Blank52")
        
        // CG - Get the formatted price string for display in the subtitle
        //let formattedPrice: NSString = NSString(format: "£%.2f", rowData["trackPrice"] as Double)
        
        let formattedPrice = album.price
        
        // Jump in to a background thread to get the image for this item
        
        // Grab the artworkUrl60 key to get an image URL for the app's thumbnail
        //let urlString = rowData["artworkUrl60"] as String
        
        let urlString = album.thumbnailImageURL
        
        // Check our image cache for the existing key. This is just a dictionary of UIImages
        var image = self.imageCache[urlString]
        
        if( image == nil ) {
            
            // If the image does not exist, we need to download it
            var imgURL: NSURL = NSURL(string: urlString)!
            
            // Download an NSData representation of the image at the URL
            let request: NSURLRequest = NSURLRequest(URL: imgURL)
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
                if error == nil {
                    image = UIImage(data: data)
                    
                    // Store the image in to our cache
                    self.imageCache[urlString] = image
                    dispatch_async(dispatch_get_main_queue(), {
                        if let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath) {
                            cellToUpdate.imageView.image = image
                        }
                    })
                }
                else {
                    println("Error: \(error.localizedDescription)")
                }
            })
            
        }
            
        // CG - Otherwise if we are able to get our image from the cache.. load it.
        else {
            dispatch_async(dispatch_get_main_queue(), {
                if let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath) {
                    cellToUpdate.imageView.image = image
                }
            })
        }
        
        cell.detailTextLabel?.text = formattedPrice
        
        return cell
    }
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // CG - Set the delegate of the 'APIController' object to this class so that we can call the 'didReceiveAPIResults' method from the 'APIController'.
        //self.api.delegate = self;
        
        // CG - Pass in 'SearchResultsViewController' as delegate into APIController constuctor.
        api = APIController(newDelegate: self);
        
        // CG - Show the network activity icon in the status bar.
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true;
        
        // CG - We now need to force unwrap the 'api' Optional variable value in order to call its 'searchItunesFor()' method.
        api!.searchItunesFor("Avicii")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}