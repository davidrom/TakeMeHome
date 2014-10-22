//
//  ViewController.swift
//  TakeMeHome
//
//  Created by Romain on 9/26/14.
//  Copyright (c) 2014 Romain. All rights reserved.
//

import UIKit
import CoreLocation

// class ViewController: UIViewController {
class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var homeAddressTextField: UITextField!

    // var manager:CLLocationManager!
    let locationManager = CLLocationManager()
    var currentLocation = Location()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Temporary assign Home Address and lat and long
        homeAddressTextField.text = "300 3rd Street, San Francisco, CA 94107"
        
        // Core Location
//        manager = CLLocationManager()
//        manager.delegate = self
//        manager.desiredAccuracy = kCLLocationAccuracyBest
//        manager.requestWhenInUseAuthorization()
//        manager.startUpdatingLocation()

        self.locationManager.requestWhenInUseAuthorization()
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }

    }

    // Get the current location
    func locationManager(manager:CLLocationManager!, didUpdateLocations locations:[AnyObject]!) {
        
        // var userLocation:CLLocation = locations[0] as CLLocation
        var locValue:CLLocationCoordinate2D = manager.location.coordinate
        currentLocation.latitude = Float(locValue.latitude)
        currentLocation.longitude = Float(locValue.longitude)
        
        // var latitude:CLLocationDegrees = userLocation.coordinate.latitude
        // var longitude:CLLocationDegrees = userLocation.coordinate.longitude
        
        // println("latitude = \(latitude)")
        
        // println("locations = \(locValue.latitude) \(locValue.longitude)")

        
        // currentLocation.latitude = Float(latitude)
        // currentLocation.longitude = Float(longitude)
        

        
    }
    
    func locationManager(manager:CLLocationManager, didFailWithError error:NSError)
    {
        println(error)
    }
    
    func getUberProducts() {
        
        println("Current latitude = \(currentLocation.latitude)")
        println("Current longitude = \(currentLocation.longitude)")

        // Get Product IDs from Uber based on current location
        let uberServerToken = "LvdBuokARs90l83vrt_77hmcD222EI094JL86B0Q"
        let urlPath = "https://api.uber.com/v1/products?latitude=\(currentLocation.latitude)&longitude=\(currentLocation.longitude)"
        let url = NSURL(string: urlPath)
        let session = NSURLSession.sharedSession()
        var request = NSMutableURLRequest(URL: url!)
        request.setValue("Token \(uberServerToken)", forHTTPHeaderField: "Authorization")
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            
            if (error != nil) {
                println(error)
            }
            else {
                let jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary
                println(jsonResult)
                // println("product id = ")
                // let myproduct = jsonResult(["products"]["product_id"].array)
                var productId = jsonResult["products"]?[0]["product_id"]
                // println(jsonResult["products"]?[0]["product_id"])
                println(productId)
            }
        })
        task.resume()
    }
    

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func takeMeHomeButtonPressed(sender: AnyObject) {
        
        // Remove keyboard
        homeAddressTextField.resignFirstResponder()
        
        getUberProducts()
        
        var homeAddress:String = homeAddressTextField.text
        var geocoder = CLGeocoder()

        geocoder.geocodeAddressString(homeAddress, {(placemarks: [AnyObject]!, error: NSError!) -> Void in
            if let placemark = placemarks?[0] as? CLPlacemark {
                var homeLatitude = placemark.location.coordinate.latitude
                var homeLongitude = placemark.location.coordinate.longitude
                //self.mapView.addAnnotation(MKPlacemark(placemark: placemark))
                println("Home Latidude: \(homeLatitude)")
                println("Home Longitude: \(homeLongitude)")

                var encodedAddressString:String = homeAddress.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
                // println("URL-encoded Home Address: \(encodedAddressString)")
                
                if encodedAddressString != ""
                {
                    encodedAddressString = encodedAddressString.stringByReplacingOccurrencesOfString(",", withString: "%2C", options: NSStringCompareOptions.LiteralSearch, range: nil)
                }
                
                // println("\(homeAddress.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)")
                
                println("home address = \(homeAddress)")
                println("encoded home address = \(encodedAddressString)")
                
                var dropoffAddress:String = "Home%20(" + "\(encodedAddressString)" + ")"
                
                var uberDeepLink:String = "uber://?action=setPickup&pickup[latitude]=\(self.currentLocation.latitude)&pickup[longitude]=\(self.currentLocation.longitude)"
                uberDeepLink += "&pickup[nickname]=UberHQ&pickup[formatted_address]=1455%20Market%20St%2C%20San%20Francisco%2C%20CA%2094103"
                uberDeepLink += "&dropoff[latitude]=\(homeLatitude)&dropoff[longitude]=\(homeLongitude)"
                uberDeepLink += "&dropoff[nickname]=\(dropoffAddress)&dropoff[formatted_address]=\(encodedAddressString)"
                uberDeepLink += "&product_id=a1111c8c-c720-46c3-8534-2fcdd730040d"
                
                println("uberDeepLink = \(uberDeepLink)")
                
                let url = NSURL(string: uberDeepLink)

                
                // If Uber is installed on the device, then launch the app
                // UIApplication.sharedApplication().openURL(NSURL.URLWithString(uberDeepLink))
                UIApplication.sharedApplication().openURL(url!)
            }
        })
        
        
//        var encodedAddressString = homeAddress.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())
//        
        

        
        
        
        // If Uber is installed on the device, then launch the app
        // var uberDeepLink = "uber://?action=setPickup&pickup=my_location&dropoff[formatted_address]=1455%20Market%20St%2C%20San%20Francisco%2C%20CA%2094103";
        // var uberDeepLink = "uber://?action=setPickup&pickup=my_location&dropoff[latitude]=37.771026&dropoff[longitude]=-122.404051&dropoff[formatted_address]=699%208th%20St%2C%20San%20Francisco%2C%20CA%2094103&product_id=b5e74e96-5d27-4caf-83e9-54c030cd6ac5"
        
        // From Uber doc
        // uber://?action=setPickup&pickup[latitude]=37.775818&pickup[longitude]=-122.418028&pickup[nickname]=UberHQ&pickup[formatted_address]=1455%20Market%20St%2C%20San%20Francisco%2C%20CA%2094103&dropoff[latitude]=37.802374&dropoff[longitude]=-122.405818&dropoff[nickname]=Coit%20Tower&dropoff[formatted_address]=1%20Telegraph%20Hill%20Blvd%2C%20San%20Francisco%2C%20CA%2094133&product_id=a1111c8c-c720-46c3-8534-2fcdd730040d
        
        
        // If Uber app is not installed on the device
        // uberDeepLink = "https://www.uber.com/invite/drv52"
    
        
        

        

        
        
        
        
        
        // [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms://itunes.com/apps/Reactors"]]
        
        /*
        
        NSString *urlAddress = @”http://www.google.com”
        
        //Create a URL object.
        NSURL *url = [NSURL URLWithString:urlAddress];
        
        //URL Requst Object
        NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
        
        //Load the request in the UIWebView.
        [webView loadRequest:requestObj];
   
        */

    }
    

    

}

