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
    var count = 0
    
    var dayOneData = [String: Any]()
    var dayTwoData = [String: Any]()
    var dayThreeData = [String: Any]()
    var dayFourData = [String: Any]()
    var dayFiveData = [String: Any]()
    
    func gettingWeatherData(lat: Double, lon: Double, completion: @escaping (_ weatherData: WeatherData) -> ()) {
        
        guard let url = URL(string: "http://api.openweathermap.org/data/2.5/forecast/daily") else { return }
        
        let parameters: [String: Any] = ["lat": lat, "lon": lon, "lang": "ru", "appid": Constants.OpenWeatherMap.apiKey]
        
        if count < 1 { // tempopary hardcode to limit the number of requests to openweathermap :(
            session.request(url, method: .get, parameters: parameters).responseJSON { dataResponse in
                switch dataResponse.result {
                    
                case .success(let value):
                    
                var daysArray = [self.dayOneData, self.dayTwoData, self.dayThreeData, self.dayFourData, self.dayFiveData]
                let json = JSON(value)
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd MMM"
                dateFormatter.locale = Locale(identifier: "ru_RU")
                
                //putting the weather forecast data into dictionaries
                for i in 0..<daysArray.count {
                    daysArray[i]["date"] = dateFormatter.string(from: Date(timeIntervalSince1970: (json["list"][i]["dt"].double)!))
                    daysArray[i]["temperature"] = json["list"][i]["temp"]["day"].double
                    daysArray[i]["weatherState"] = json["list"][i]["weather"][self.index]["description"].string
                    daysArray[i]["city"] = json["city"]["name"].string
                }
                
                DispatchQueue.main.async {
                    completion(WeatherData(fiveDaysForecast: daysArray))
                }
                    self.count += 1
                
            case .failure(let error):
                print (error)
                }
            }
        }
    }
}
