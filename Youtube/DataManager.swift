//
//  DataManager.swift
//  Swift Radio
//
//  Created by Matthew Fecher on 3/24/15.
//  Copyright (c) 2015 MatthewFecher.com. All rights reserved.
//

import UIKit

class DataManager {
    
    //*****************************************************************
    // Helper class to get either local or remote JSON
    //*****************************************************************
    
    class func getStationDataWithSuccess(success: @escaping ((_ metaData: Data?) -> Void)) {

        DispatchQueue.global(qos: .userInitiated).async {
            if useLocalStations {
                loadDataFromURL(url: URL(string: urlstring)!) { data, error in
                    if let urlData = data {
                        success(urlData)
                    }
                }

            } else {
                print("Nothing")
            }
        }
    }
    
    //*****************************************************************
    // Load local JSON Data
    //*****************************************************************
    
    class func getDataFromFileWithSuccess(success: (_ data: Data) -> Void) {
        var urlstring: String!
        urlstring = "http://nextapps.org/iOS/banglacartoon/cartoonretrive.php"
        let jsonFile = NSURL(string: urlstring)
        
        let jsonData = try? Data(contentsOf: jsonFile! as URL)
        
         _ = DataManager.parseJSONFromData(jsonData)
        
        
        
    }
    
    //*****************************************************************
    // Get LastFM/iTunes Data
    //*****************************************************************
    
    class func getTrackDataWithSuccess(queryURL: String, success: @escaping ((_ metaData: Data?) -> Void)) {

        loadDataFromURL(url: URL(string: queryURL)!) { data, _ in
            // Return Data
            if let urlData = data {
                success(urlData)
            } else {
                if kDebugLog { print("API TIMEOUT OR ERROR") }
            }
        }
    }
    
    //*****************************************************************
    // REUSABLE DATA/API CALL METHOD
    //*****************************************************************
    
    class func loadDataFromURL(url: URL, completion:@escaping (_ data: Data?, _ error: Error?) -> Void) {
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.allowsCellularAccess          = true
        sessionConfig.timeoutIntervalForRequest     = 15
        sessionConfig.timeoutIntervalForResource    = 30
        sessionConfig.httpMaximumConnectionsPerHost = 1
        
        let session = URLSession(configuration: sessionConfig)
        
        // Use NSURLSession to get data from an NSURL
        let loadDataTask = session.dataTask(with: url){ data, response, error in
            if let responseError = error {
                completion(nil, responseError)
                
                if kDebugLog { print("API ERROR: \(String(describing: error))") }
                
                // Stop activity Indicator
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
            } else if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    let statusError = NSError(domain:"com.matthewfecher", code:httpResponse.statusCode, userInfo:[NSLocalizedDescriptionKey : "HTTP status code has unexpected value."])
                    
                    if kDebugLog { print("API: HTTP status code has unexpected value") }
                    
                    completion(nil, statusError)
                    
                } else {
                    
                    // Success, return data
                    completion(data, nil)
                }
            }
        }
        
        loadDataTask.resume()
    }
    
    
}
extension DataManager
{
    static func parseJSONFromData(_ jsonData: Data?) -> [String : AnyObject]?
    {
        if let data = jsonData {
            do {
                let jsonDictionary = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String : AnyObject]
                return jsonDictionary
                
            } catch let error as NSError {
                print("error processing json data: \(error.localizedDescription)")
            }
        }
        
        return nil
}
}
