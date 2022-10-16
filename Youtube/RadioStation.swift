//
//  RadioStation.swift
//  Swift Radio
//
//  Created by Matthew Fecher on 7/4/15.
//  Copyright (c) 2015 MatthewFecher.com. All rights reserved.
//

import UIKit

//*****************************************************************
// Radio Station
//*****************************************************************

// Class inherits from NSObject so that you may easily add features
// i.e. Saving favorite stations to CoreData, etc

class RadioStation: NSObject {
    
    var stationName     : String
    var stationStreamURL: String
    var stationImageURL : String
   // var stationDesc     : String
    //var stationLongDesc : String
    
    init(imageURL: String,name: String, streamURL: String ) {
        self.stationName      = name
        self.stationStreamURL = streamURL
        self.stationImageURL  = imageURL
      //  self.stationDesc      = desc
       // self.stationLongDesc  = longDesc
    }
    
   
    
    //*****************************************************************
    // MARK: - JSON Parsing into object
    //*****************************************************************
    
    class func parseStation(stationJSON: JSON) -> (RadioStation) {
        
        let name      = stationJSON["snippet"]["title"].string ?? ""
       let streamURL = stationJSON["id"]["videoId"].string ?? ""
        let imageURL  = stationJSON["snippet"]["thumbnails"]["high"]["url"].string ?? ""
        //let desc      = stationJSON["desc"].string ?? ""
        //let longDesc  = stationJSON["longDesc"].string ?? ""
        
        let station = RadioStation( imageURL: imageURL,name: name, streamURL: streamURL)
        return station
    }

}
