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
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startMonitoringSignificantLocationChanges()
        slides = createSlides()
        setupSlideScrollView(slides: slides)
        pageScroller.numberOfPages = slides.count
        pageScroller.currentPage = 0
        view.bringSubview(toFront: pageScroller)
    }
    
    func updateUI2(_ weatherData: WeatherData) {
        let date = Date(timeIntervalSince1970: weatherData.date!)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM"
        dateFormatter.locale = Locale(identifier: "ru_RU")
        
        for i in 0..<slides.count {
            slides[i].dateSlideLabel.text = dateFormatter.string(from: date)
            slides[i].citySlideLabel.text = weatherData.city
            slides[i].weatherStateSlideLabel.text = weatherData.weatherState
            if let temp = weatherData.temperature {
                slides[i].tamperatureSlideLabel.text = "\(round(temp - 273.15))˚"
            }
        }
    }
    
    func createSlides() -> [Slide]{
        let slide1: Slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
         let slide2: Slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
         let slide3: Slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
         let slide4: Slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
         let slide5: Slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
        return [slide1, slide2, slide3, slide4, slide5]
    }
    
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
        WeatherDownloader.sharedWeatherInstance.gettingWeatherData(lat: latitude, lon: longtitude, complition: { (weatherData) in
            self.updateUI2(weatherData)
        })
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        loadWeatherAndUpdateUI()
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


