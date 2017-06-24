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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        slideScrollView.delegate = self
        locationManager.delegate = self as CLLocationManagerDelegate
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
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
    
    //updating labels values for views
    func updateUI3(_ weatherData: WeatherData) {
        for i in 0..<slides.count {
                slides[i].dateSlideLabel.text = (weatherData.fiveDaysForecast[i]["date"] as! String)
                slides[i].citySlideLabel.text = (weatherData.fiveDaysForecast[i]["city"] as! String)
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
                    } else { // if temperature == 0
                         slides[i].temperatureSlideLabel.text = "\(round(temp as! Double - 273.15))˚"
                    }
                }
                if let weatherState = weatherData.fiveDaysForecast[i]["weatherState"] as? String {
                    slides[i].weatherStateSlideLabel.text = weatherState
                    slides[i].weatherStateSlideIcon.image = UIImage(named: weatherState)
            }
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
    
    func loadWeatherAndUpdateUI() {
        guard let latitude = locationManager.location?.coordinate.latitude else { return }
        guard let longtitude = locationManager.location?.coordinate.longitude else { return }
        WeatherDownloader.sharedWeatherInstance.gettingWeatherData(lat: latitude, lon: longtitude, completion: { (weatherData) in
            self.updateUI3(weatherData)
        })
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
}

extension ViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            loadWeatherAndUpdateUI()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        loadWeatherAndUpdateUI()
    }
}


