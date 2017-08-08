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
    
    var dayOneData = [String: Any]()
    var dayTwoData = [String: Any]()
    var dayThreeData = [String: Any]()
    var dayFourData = [String: Any]()
    var dayFiveData = [String: Any]()
    
    func gettingWeatherData(lat: Double, lon: Double, completion: @escaping (_ weatherData: WeatherData) -> ()) {
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 15 // seconds
        
        guard let url = URL(string: "http://api.openweathermap.org/data/2.5/forecast/daily") else { return }
        
        let parameters: [String: Any] = ["lat": lat, "lon": lon, "lang": "eng", "appid": Constants.OpenWeatherMap.apiKey]
        
        session.request(url, method: .get, parameters: parameters).responseJSON { dataResponse in
                switch dataResponse.result {
                    
            case .success(let value):
                    
            var daysArray = [self.dayOneData, self.dayTwoData, self.dayThreeData, self.dayFourData, self.dayFiveData]
            let json = JSON(value)
                
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMM"
            dateFormatter.locale = Locale(identifier: "en_US")
                
                //putting the weather forecast data into dictionaries
            for i in 0..<daysArray.count {
                daysArray[i]["date"] = dateFormatter.string(from: Date(timeIntervalSince1970: (json["list"][i]["dt"].double)!))
                    daysArray[i]["temperature"] = json["list"][i]["temp"]["max"].double
                    daysArray[i]["morningTemperature"] = json["list"][i]["temp"]["morn"].double
                    daysArray[i]["dayTemperature"] = json["list"][i]["temp"]["day"].double
                    daysArray[i]["nightTemperature"] = json["list"][i]["temp"]["night"].double
                    daysArray[i]["eveningTemperature"] = json["list"][i]["temp"]["eve"].double
                    daysArray[i]["weatherState"] = json["list"][i]["weather"][0]["description"].string
                    daysArray[i]["city"] = json["city"]["name"].string
                }
                
            DispatchQueue.main.async {
                completion(WeatherData(fiveDaysForecast: daysArray))
                }
                
            case .failure(let error):
                print (error)
            }
        }
    }
}
