//
//  WeatherManager.swift
//  Clima
//
//  Created by Veerjyot Singh on 30/03/22.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import UIKit
import CoreLocation

protocol WeatherManagerDelegate{
    func didUpdateWeather(_ weatherManager:WeatherManager, weather:WeatherModel)
    func didFailWithError(error:Error)
}

struct WeatherManager   {
    //my API key =07f232ff58ffdc8183d1d9a44d9f84bd
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=07f232ff58ffdc8183d1d9a44d9f84bd&units=metric"
    
    var delegate: WeatherManagerDelegate?
    func fetchWeather(longitude:CLLocationDegrees, latitude:CLLocationDegrees){
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        self.performRequest(with: urlString)
    }
    
    func fetchWeather (cityName:String){
        let urlString = "\(weatherURL)&q=\(cityName)"
        self.performRequest(with: urlString)
    }
    func performRequest (with urlString:String){
        //create a URL
        if  let url = URL(string: urlString){
            //create a URL session
            let session = URLSession(configuration: .default)
            //give the session task
            let task = session.dataTask(with: url) {(data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data{
                    if let weather = self.parseJSON(safeData) {
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            //start the task
            task.resume()
        }
    }
    func parseJSON(_ weatherData: Data) -> WeatherModel?{
        //how the data is structured
        let decoder = JSONDecoder()
        do {
            
            let decodedData = try decoder.decode(WeatherData.self ,from: weatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            print(weather.temperatureString)
            print(weather.cityName)
            print(weather.conditionName)
            return weather
            
        }catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
        
    }
}
