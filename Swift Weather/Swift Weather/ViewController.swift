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

    @IBOutlet weak var loading: UILabel!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var imageWeather: UIImageView!
    @IBOutlet weak var temperature: UILabel!
    
    let locationManger = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let background = UIImage(named: "background.png")
        self.view.backgroundColor = UIColor(patternImage: background!)
        
        self.loadingIndicator.startAnimating()
        
        locationManger.delegate = self
        locationManger.desiredAccuracy = kCLLocationAccuracyBest
        
        if ios8() {
            locationManger.requestAlwaysAuthorization()
        }
        
        locationManger.startUpdatingLocation()
    }
    
    func ios8() -> Bool {
        print(UIDevice.currentDevice().systemVersion)
        
        let dotIndex = UIDevice.currentDevice().systemVersion.rangeOfString(".")
        
        let vesion = UIDevice.currentDevice().systemVersion.substringToIndex((dotIndex?.startIndex)!)
        
        let dVesion:Int = Int(vesion)!
        
        return dVesion > 7
//        return UIDevice.currentDevice().systemVersion == "9.1"
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
                
                self.updateUISuccess(responseObject)
            },
            failure: { (operation: AFHTTPRequestOperation!,
                error: NSError!) in
                print("Error: " + error.localizedDescription)
        })
    }
    
    func updateUISuccess(responseObject: AnyObject!) {
        self.loading.text = nil
        self.loadingIndicator.hidden = true
        self.loadingIndicator.stopAnimating()
        
        if let jsonResult = responseObject as? NSDictionary {
            
            let tempResult = jsonResult["main"]?["temp"] as! Double
            var temperature: Double
            if (jsonResult["sys"]?["country"] as! String == "US") {
                // Convert temperature to Fahrenheit if user is within the US
                temperature = round(((tempResult - 273.15) * 1.8) + 32)
            }
            else {
                // Otherwise, convert temperature to Celsius
                temperature = round(tempResult - 273.15)
            }
            // Is it a bug of Xcode 6? can not set the font size in IB.
            self.temperature.font = UIFont.boldSystemFontOfSize(60)
            self.temperature.text = "\(temperature)°"
            
            let name = jsonResult["name"]! as! String
            self.location.font = UIFont.boldSystemFontOfSize(25)
            self.location.text = "\(name)"
            
            let condition = jsonResult["weather"]?[0]!["id"] as! Int
            let sunrise = jsonResult["sys"]?["sunrise"] as! Double
            let sunset = jsonResult["sys"]?["sunset"] as! Double
            
            var nightTime = false
            let now = NSDate().timeIntervalSince1970
            // println(nowAsLong)
            
            if (now < sunrise || now > sunset) {
                nightTime = true
            }
            self.updateWeatherIcon(condition, nightTime: nightTime)
        }
    }
    
    // Converts a Weather Condition into one of our icons.
    // Refer to: http://bugs.openweathermap.org/projects/api/wiki/Weather_Condition_Codes
    func updateWeatherIcon(condition: Int, nightTime: Bool) {
        // Thunderstorm
        if (condition < 300) {
            if nightTime {
                self.imageWeather.image = UIImage(named: "tstorm1_night")
            } else {
                self.imageWeather.image = UIImage(named: "tstorm1")
            }
        }
            // Drizzle
        else if (condition < 500) {
            self.imageWeather.image = UIImage(named: "light_rain")
        }
            // Rain / Freezing rain / Shower rain
        else if (condition < 600) {
            self.imageWeather.image = UIImage(named: "shower3")
        }
            // Snow
        else if (condition < 700) {
            self.imageWeather.image = UIImage(named: "snow4")
        }
            // Fog / Mist / Haze / etc.
        else if (condition < 771) {
            if nightTime {
                self.imageWeather.image = UIImage(named: "fog_night")
            } else {
                self.imageWeather.image = UIImage(named: "fog")
            }
        }
            // Tornado / Squalls
        else if (condition < 800) {
            self.imageWeather.image = UIImage(named: "tstorm3")
        }
            // Sky is clear
        else if (condition == 800) {
            if (nightTime){
                self.imageWeather.image = UIImage(named: "sunny_night") // sunny night?
            }
            else {
                self.imageWeather.image = UIImage(named: "sunny")
            }
        }
            // few / scattered / broken clouds
        else if (condition < 804) {
            if (nightTime){
                self.imageWeather.image = UIImage(named: "cloudy2_night")
            }
            else{
                self.imageWeather.image = UIImage(named: "cloudy2")
            }
        }
            // overcast clouds
        else if (condition == 804) {
            self.imageWeather.image = UIImage(named: "overcast")
        }
            // Extreme
        else if ((condition >= 900 && condition < 903) || (condition > 904 && condition < 1000)) {
            self.imageWeather.image = UIImage(named: "tstorm3")
        }
            // Cold
        else if (condition == 903) {
            self.imageWeather.image = UIImage(named: "snow5")
        }
            // Hot
        else if (condition == 904) {
            self.imageWeather.image = UIImage(named: "sunny")
        }
        else {
            // Weather condition not available
            self.imageWeather.image = UIImage(named: "dunno")
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
        self.loadingIndicator.hidden = true
        self.loadingIndicator.stopAnimating()
        self.loading.text = error.description
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

