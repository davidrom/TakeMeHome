// Playground - noun: a place where people can play

import UIKit

var x = 2

var request = NSMutableURLRequest(URL: NSURL(string: "https://api.uber.com/v1/products"))
var session = NSURLSession.sharedSession()
request.HTTPMethod = "GET"

var params = ["server_token":"LvdBuokARs90l83vrt_77hmcD222EI094JL86B0Q", "latitude":"37.7758181", "longitude":"-122.418028"] as Dictionary<String, String>

println("Description: \(request.description)")

var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
