//
//  ViewController.swift
//  TakeMeHome
//
//  Created by Romain on 9/26/14.
//  Copyright (c) 2014 Romain. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var homeAddressTextField: UITextField!

    let locationManager = CLLocationManager()
    var currentLocation = Location()
    var uberProductId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Temporary assign Home Address
        homeAddressTextField.text = "300 3rd Street, San Francisco, CA 94107"
        
        self.locationManager.requestWhenInUseAuthorization()
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }

    // Get user's current location
    func locationManager(manager:CLLocationManager!, didUpdateLocations locations:[AnyObject]!) {
        var locValue:CLLocationCoordinate2D = manager.location.coordinate
        currentLocation.latitude = Float(locValue.latitude)
        currentLocation.longitude = Float(locValue.longitude)
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
                self.uberProductId = jsonResult["products"]?[0]["product_id"] as NSString
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
                println("Home Latidude: \(homeLatitude)")
                println("Home Longitude: \(homeLongitude)")

                var encodedAddressString:String = homeAddress.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
                
                if encodedAddressString != ""
                {
                    encodedAddressString = encodedAddressString.stringByReplacingOccurrencesOfString(",", withString: "%2C", options: NSStringCompareOptions.LiteralSearch, range: nil)
                }
                
                println("home address = \(homeAddress)")
                println("encoded home address = \(encodedAddressString)")
                
                // Wait until the app hears back from Uber
                while self.uberProductId.isEmpty {
                    
                }
                
                var dropoffAddress:String = "Home%20(" + "\(encodedAddressString)" + ")"
    
                var uberDeepLink:String = "uber://?action=setPickup&pickup[latitude]=\(self.currentLocation.latitude)&pickup[longitude]=\(self.currentLocation.longitude)"
                // uberDeepLink += "&pickup[nickname]=UberHQ&pickup[formatted_address]=1455%20Market%20St%2C%20San%20Francisco%2C%20CA%2094103"
                // uberDeepLink += "&pickup[nickname]=Current Location&pickup[formatted_address]=1455%20Market%20St%2C%20San%20Francisco%2C%20CA%2094103"
                uberDeepLink += "&dropoff[latitude]=\(homeLatitude)&dropoff[longitude]=\(homeLongitude)"
                uberDeepLink += "&dropoff[nickname]=\(dropoffAddress)&dropoff[formatted_address]=\(encodedAddressString)"
                uberDeepLink += "&product_id=\(self.uberProductId)"
                
                println("uberDeepLink = \(uberDeepLink)")
                println("product id = \(self.uberProductId)")
                
                let url = NSURL(string: uberDeepLink)

                
                // If Uber is installed on the device, then launch the app, if not redirect user to sign up page in Safari
                let uberURLScheme = NSURL(string: "uber://")
                if UIApplication.sharedApplication().canOpenURL(uberURLScheme!) {
                    // let canOpen = UIApplication.sharedApplication().canOpenURL(uberAppURL)
                    let canOpen = UIApplication.sharedApplication().openURL(url!)
                    // println("Can open \"\(uberURLScheme)\": \(canOpen)")
                }
                else {
                    let signupURL = NSURL(string: "https://www.uber.com/invite/drv52")
                    UIApplication.sharedApplication().openURL(signupURL!)
                    // UIApplication.sharedApplication().openURL(NSURL(string: "http://www.stackoverflow.com"))
                }
                
                
            }
        })
      
    
        
    
    }
    
    
    @IBAction func getEstimatesButtonPressed(sender: AnyObject) {
        
    }
    

}

