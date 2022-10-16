//
//  SwiftRadio-Settings.swift
//  Swift Radio
//
//  Created by Matthew Fecher on 7/2/15.
//  Copyright (c) 2015 MatthewFecher.com. All rights reserved.
//

import Foundation

//**************************************
// GENERAL SETTINGS
//**************************************

// Display Comments
let kDebugLog = true

//**************************************
// STATION JSON
//**************************************

// If this is set to "true", it will use the JSON file in the app
// Set it to "false" to use the JSON file at the stationDataURL

let useLocalStations = true
let stationDataURL   = ""
let urlstring = "https://www.googleapis.com/youtube/v3/search?part=snippet&maxResults=50&q=bangla+songs+2017&type=video&videoEmbeddable=true&key=AIzaSyDPPZz-bIoz2qrtnhBwBkkkXEmI-swD08Q"
//**************************************
// SEARCH BAR
//**************************************

// Set this to "true" to enable the search bar
let searchable = true

//**************************************
// LASTFM API
//**************************************

// Use LastFM or iTunes API
// set to "false" to use iTunes
let useLastFM = false

// IF YOU USE LASTFM, PLEASE USE YOUR OWN KEY
// Visit: http://www.last.fm/api

let apiKey    = "9a267c245324cfa4f887366d497d3dd3"
let apiSecret = "f1191864d7ae71e580b89238129768b8"

