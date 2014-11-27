//
//  APIController.swift
//  HelloWorld
//
//  Created by Connor Goddard on 27/11/2014.
//  Copyright (c) 2014 Connor Goddard. All rights reserved.
//

import Foundation

protocol APIControllerProtocol {
    func didReceiveAPIResults(results: NSDictionary)
}

class APIController {
    
    var delegate: APIControllerProtocol?
    
    init() {
        
    }
    
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
                    
                } else {
                    
                    // CG - Create new NSError object that is optional (i.e. may or may not contain a value)
                    var err: NSError?
                    
                    // CG - Parse the returned JSON response (data), passing in the 'err' variable created above.
                    var jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as NSDictionary
                    
                    // CG - Deal with any errors resulting from the JSON parsing.
                    if(err != nil) {
                        // If there is an error parsing JSON, print it to the console
                        println("JSON Error \(err!.localizedDescription)")
                    }
                    
                    //CG - Get the 'results' array from the JSON file.
                    let results: NSArray = jsonResult["results"] as NSArray
                    
                    // CG - Now we will call the 'didReceiveAPIResults' method from the 'APIController' delegate (SearchViewController)
                    self.delegate?.didReceiveAPIResults(jsonResult)

                }
                
                
            })
            
            // CG - Begin the actual asynchronous request.
            task.resume()
        }
    }
    
}
