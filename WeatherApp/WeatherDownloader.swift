//
//  WeatherDownloader.swift
//  WeatherApp
//
//  Created by Ольга Клюшкина on 14.06.17.
//  Copyright © 2017 klyushkina. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON


class WeatherDownloader {
    static var sharedWeatherInstance = WeatherDownloader()
    let session = Alamofire.SessionManager.default
    var index = 0
    var counter = 0
    
    func gettingWeatherData(lat: Double, lon: Double, complition: @escaping (_ weatherData: WeatherData) -> ()) {
        
        guard let url = URL(string: "http://api.openweathermap.org/data/2.5/forecast") else { return }
        
        var dateArray = [Double]()
        
        let parameters: [String: Any] = ["lat": lat, "lon": lon, "lang": "ru", "appid": Constants.OpenWeatherMap.apiKey]
        
        session.request(url, method: .get, parameters: parameters).responseJSON { dataResponse in
            switch dataResponse.result {
            case .success(let value):
                
                let json = JSON(value)
                guard let date = json["list"][self.index]["dt"].double else {return}
                for index in 0...4 {
                    dateArray.append(json["list"][index]["dt"].double!)
                }
                
                guard let city = json["city"]["name"].string else {return}
                guard let temperature = json["list"][self.index]["main"]["temp"].double else {return}
                guard let weatherState = json["list"][self.index]["weather"][self.index]["description"].string else {return}
                
                DispatchQueue.main.async {
                    complition(WeatherData(city: city, date: date, temperature: temperature, weatherState: weatherState))
                }
                
            case .failure(let error):
                print (error)
            }
        }
    }
}
