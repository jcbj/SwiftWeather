//
//  ViewController.swift
//  Swift Weather
//
//  Created by jiangchao on 15/11/6.
//  Copyright © 2015年 jiangchao. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController ,CLLocationManagerDelegate{

    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var imageWeather: UIImageView!
    @IBOutlet weak var temperature: UILabel!
    
    let locationManger = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let background = UIImage(named: "background.png")
        self.view.backgroundColor = UIColor(patternImage: background!)
        
        locationManger.delegate = self
        locationManger.desiredAccuracy = kCLLocationAccuracyBest
        
        if ios8() {
            locationManger.requestAlwaysAuthorization()
        }
        
        locationManger.startUpdatingLocation()
    }
    
    func ios8() -> Bool {
        print(UIDevice.currentDevice().systemVersion)
        return UIDevice.currentDevice().systemVersion == "9.1"
    }

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location:CLLocation = locations[locations.count - 1]
        
        if location.horizontalAccuracy > 0 {
            print(location.coordinate.latitude)
            print(location.coordinate.longitude)
            self.updateWeatherInfo(location.coordinate.latitude,longitude:location.coordinate.longitude)
            locationManger.stopUpdatingLocation()
        }
    }
    
    func updateWeatherInfo(latitude:CLLocationDegrees,longitude:CLLocationDegrees) {
        let manager = AFHTTPRequestOperationManager()
        let url = "http://api.openweathermap.org/data/2.5/weather"
        
        let params = ["lat":latitude,"lon":longitude,"cnt":0]
        
        manager.GET(url,
            parameters: params,
            success: { (operation: AFHTTPRequestOperation!,
                responseObject: AnyObject!) in
                print("JSON: " + responseObject.description!)
            },
            failure: { (operation: AFHTTPRequestOperation!,
                error: NSError!) in
                print("Error: " + error.localizedDescription)
        })
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

