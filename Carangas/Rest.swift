//
//  Rest.swift
//  Carangas
//
//  Created by Usuário Convidado on 14/04/18.
//  Copyright © 2018 Eric Brito. All rights reserved.
//

import Foundation

enum CarError {
    case url
    case noResponse
    case noData
    case invalidJSON
    case taskError(error: NSError)
    case responseStatusCode(cod: Int)
    
}

enum RESTOperation {
    case update
    case delete
    case save
}

class REST {
    
    private static let basePath = "https://carangas.herokuapp.com/cars"
    private static let basePathFipe = "https://fipeapi.appspot.com/api/1/carros/marcas.json"
    
    private static let configuration: URLSessionConfiguration = {
        let config = URLSessionConfiguration.default
        config.allowsCellularAccess = true
        config.httpAdditionalHeaders = ["Content-Type": "application/json"]
        config.timeoutIntervalForRequest = 40.4
        config.httpMaximumConnectionsPerHost = 4
        return config
    }()
    
    private static let session = URLSession(configuration: configuration)
 
    class func loadBrand(onComplete: @escaping ([Fipe]) -> Void, onError: @escaping (Bool) -> Void){
        guard let url = URL(string: basePathFipe) else {
            onError(true)
            return
        }
        
        let task = session.dataTask(with: url) { (data, response, erro) in
            if erro != nil {
                onError(true)
                return
            } else {
                guard let response = response as? HTTPURLResponse else {
                    onError(true)
                    return
                }
                
                if response.statusCode == 200 {
                    guard let data = data else {
                        onError(true)
                        return
                    }
                    do {
                        let fipes = try JSONDecoder().decode([Fipe].self, from: data)
                        onComplete(fipes)
                    } catch {
                        onError(true)
                    }
                }
            }
        }
        
        task.resume()
    }
    
    class func loadCars(onComplete: @escaping ([Car]) -> Void, onError: @escaping (CarError) -> Void) {
        guard let url = URL(string: basePath) else {
            onError(.url)
            return
            
        }
        
        let dataTask = session.dataTask(with: url) { (data, response, erro) in
            if erro != nil {
                onError(.taskError(error: erro! as NSError))
            } else {
                guard let response = response as? HTTPURLResponse else {
                    onError(.noResponse)
                    return
                }
                if response.statusCode == 200 {
                    guard let data = data else {
                        onError(.noData)
                        return
                    }
                    do {
                        let cars = try JSONDecoder().decode([Car].self, from: data)
                        onComplete(cars)
                    } catch {
                        onError(.invalidJSON)
                    }
                   
                } else {
                    onError(.responseStatusCode(cod: response.statusCode))
                }
            }
        }
        
        dataTask.resume()
    }
    
    class func saveCar (_ car: Car, onComplete: @escaping  (Bool) -> Void) {
        applyOperation(car: car, operation: .save, onComplete: onComplete)
    }
    
    
    class func updateCar (_ car: Car, onComplete: @escaping  (Bool) -> Void) {
         applyOperation(car: car, operation: .update, onComplete: onComplete)
    }
    
    
    class func deleteCar (_ car: Car, onComplete: @escaping  (Bool) -> Void) {
         applyOperation(car: car, operation: .delete, onComplete: onComplete)
    }
    
    class func applyOperation(car: Car, operation: RESTOperation,
                              onComplete: @escaping (Bool) -> Void) {
        
        let urlString = basePath + "/" + (car._id ?? "")
        var httpMethod = "GET"
        switch operation {
        case .save:
            httpMethod = "POST"
        case .delete:
            httpMethod = "DELETE"
        case .update:
            httpMethod = "PUT"
        }
        
        guard let url = URL(string: urlString) else {
            onComplete(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        request.httpBody = try! JSONEncoder().encode(car)
        
        session.dataTask(with: request) { (data, response, erro) in
            if erro == nil {
                guard let response = response as? HTTPURLResponse else {
                    onComplete(false)
                    return
                }
                
                if response.statusCode == 200 {
                    onComplete(true)
                }else {
                    onComplete(false)
                }
                
            }else {
                onComplete(false)
            }
        }.resume()
        
    }
    
}
