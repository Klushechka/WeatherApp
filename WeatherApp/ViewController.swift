//
//  ViewController.swift
//  WeatherApp
//
//  Created by Ольга Клюшкина on 13.06.17.
//  Copyright © 2017 klyushkina. All rights reserved.
//

import UIKit
import CoreLocation
import Foundation

class ViewController: UIViewController, UIScrollViewDelegate {
    @IBOutlet weak var pageScroller: UIPageControl!
    @IBOutlet weak var slideScrollView: UIScrollView!
    
    var locationManager = CLLocationManager()
    var slides = [Slide]()
    var pageIndex: CGFloat? = nil
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        slideScrollView.delegate = self
        locationManager.delegate = self as CLLocationManagerDelegate
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startMonitoringSignificantLocationChanges()
        locationManager.distanceFilter = 20
        locationManager.startUpdatingLocation()
        
        slides = createSlides()
        setupSlideScrollView(slides: slides)
        
        pageScroller.numberOfPages = slides.count
        pageScroller.currentPage = 0
        view.bringSubview(toFront: pageScroller)
    }
    
    func startShowingActivityIndicator() {
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
    UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
     func endShowingActivityIdicator() {
        activityIndicator.stopAnimating()
        
        UIApplication.shared.endIgnoringInteractionEvents()
        activityIndicator.removeFromSuperview()
    }
    //updating labels values for views
    func updateUI3(_ weatherData: WeatherData) {
        for i in 0..<slides.count {
            slides[i].dateSlideLabel.text = (weatherData.fiveDaysForecast[i]["date"] as! String)
            
           //storing/caching the data so that user would see it while starting the app in the offline
            UserDefaults.standard.set(weatherData.fiveDaysForecast[i]["date"] as! String, forKey: "date\(i)")
            
            slides[i].citySlideLabel.text = (weatherData.fiveDaysForecast[i]["city"] as! String)
            UserDefaults.standard.set(weatherData.fiveDaysForecast[i]["city"] as! String, forKey: "city")
            if let temp = weatherData.fiveDaysForecast[i]["temperature"]{
                    
                    //defining the sign (+ or -) for temperature
                var sign: String? = nil
                if (temp as! Double - 273.15) > 0 {
                        sign = "+"
                } else if (temp as! Double - 273.15) < 0 {
                        sign = "-"
                } else {
                        sign = nil
                }
                    
                    //adding the sign to the temperature if it's > 0 or < 0
                if let sign = sign {
                    slides[i].temperatureSlideLabel.text = "\(sign)\(round(temp as! Double - 273.15))˚"
                    UserDefaults.standard.set("\(sign)\(round(temp as! Double - 273.15))˚", forKey: "temperature\(i)")
                } else { // if temperature == 0
                     slides[i].temperatureSlideLabel.text = "\(round(temp as! Double - 273.15))˚"
                    UserDefaults.standard.set("\(round(temp as! Double - 273.15))˚", forKey: "temperature\(i)")
                }
            }
                if let weatherState = weatherData.fiveDaysForecast[i]["weatherState"] as? String {
                    slides[i].weatherStateSlideLabel.text = weatherState
                    UserDefaults.standard.set(weatherState, forKey: "weatherState\(i)")
                    slides[i].weatherStateSlideIcon.image = UIImage(named: weatherState)
            }
             endShowingActivityIdicator()
        }
    }
    
    //creating the views
    func createSlides() -> [Slide]{
         let slide1: Slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
         let slide2: Slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
         let slide3: Slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
         let slide4: Slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
         let slide5: Slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
        return [slide1, slide2, slide3, slide4, slide5]
    }
    
    //defining the scrollview settings
    func setupSlideScrollView(slides: [Slide]) {
        slideScrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        slideScrollView.contentSize = CGSize(width: view.frame.width * CGFloat(slides.count), height: view.frame.height)
        slideScrollView.isPagingEnabled = true
        
        for i in 0..<slides.count {
            slides[i].frame = CGRect(x: view.frame.width * CGFloat(i), y: 0, width: view.frame.width, height: view.frame.height)
            slideScrollView.addSubview(slides[i])
        }
    }
    
    //getting location and info from url + updating the UI with this info
    func loadWeatherAndUpdateUI() {
        guard let latitude = locationManager.location?.coordinate.latitude else { return }
        guard let longtitude = locationManager.location?.coordinate.longitude else { return }
        WeatherDownloader.sharedWeatherInstance.gettingWeatherData(lat: latitude, lon: longtitude, completion: { (weatherData) in
            self.updateUI3(weatherData)
        })
    }
    
    //the app will show default "--" for labels if user doesn't allow the app to get info about location
    func setLabelsValuesToDefault() {
        for i in 0..<slides.count {
            slides[i].dateSlideLabel.text = "--"
            slides[i].temperatureSlideLabel.text = "--"
            slides[i].citySlideLabel.text = "--"
            slides[i].weatherStateSlideLabel.text = "--"
            slides[i].weatherStateSlideIcon.image = nil
        }
    }
    
    //getting the number of page which is now opened
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pageIndex = round(scrollView.contentOffset.x/view.frame.width)
        if let pageNumber = pageIndex {
            pageScroller.currentPage = Int(pageNumber)
            WeatherDownloader.sharedWeatherInstance.index = pageScroller.currentPage
            print ("Page number is: \(pageScroller.currentPage)")
        }
    }
    // using viewDidAppear to make sure that ui is really ready to show the cached data
    override func viewDidAppear(_ animated: Bool) {
        for i in 0..<slides.count {
            if let temp = UserDefaults.standard.object(forKey: "temperature\(i)") {
                slides[i].temperatureSlideLabel.text = temp as? String
            }
            if let city = UserDefaults.standard.object(forKey: "city") {
                slides[i].citySlideLabel.text = city as? String
            }
            if let date = UserDefaults.standard.object(forKey: "date\(i)") {
                slides[i].dateSlideLabel.text = date as? String
            }
            if let weatherState = UserDefaults.standard.object(forKey: "weatherState\(i)") {
                slides[i].weatherStateSlideLabel.text = weatherState as? String
                slides[i].weatherStateSlideIcon.image = UIImage(named: weatherState as! String)
            }
        }
    }
}

extension ViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            startShowingActivityIndicator()
            loadWeatherAndUpdateUI()
        } else if status == .denied {
            //labels will show default "--" if the app has no access to location info
            setLabelsValuesToDefault()
            // the app will show the alert with request to give the app a permission to get location info and Settings/Cancel buttons
            let alert = UIAlertController(title: "WeatherApp doesn't know where you are", message: "Please allow the app to get your location. You can do it in Settings.", preferredStyle: UIAlertControllerStyle.alert)
            let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
                guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                    return
                }
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        print("Settings opened: \(success)") // Prints true
                    })
                }
            }
            alert.addAction(settingsAction)
            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            alert.addAction(cancelAction)
            
            present(alert, animated: true, completion: nil)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        startShowingActivityIndicator()
        loadWeatherAndUpdateUI()
    }
}


