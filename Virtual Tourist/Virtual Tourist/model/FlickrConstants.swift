//
//  FlickrConstants.swift
//  Virtual Tourist
//
//  Created by Kiko Santos on 17/12/18.
//  Copyright © 2018 Kiko Santos. All rights reserved.
//

//        Chave:
//        18ea2fc2032e3beaf79b15317a3f40fd
//
//        Segredo:
//        39e85fa11a1a6dde

import Foundation

extension FlickrClient {
    
    struct Constants {
        
        // MARK: Flickr
        struct Flickr {
            static let APIScheme = "https"
            static let APIHost = "api.flickr.com"
            static let APIPath = "/services/rest"
        }
        
        // MARK: Flickr Parameter Keys
        struct FlickrParameterKeys {
            static let Method = "method"
            static let APIKey = "api_key"
            static let Accuracy = "accuracy"
            static let Latitude = "lat"
            static let Longitude = "lon"
            static let Radius = "radius"
            static let PerPage = "per_page"
            static let Extras = "extras"
            static let Format = "format"
            static let NoJSONCallback = "nojsoncallback"
            static let SafeSearch = "safe_search"

        }
        
        // MARK: Flickr Parameter Values
        struct FlickrParameterValues {
            static let APIKey = "18ea2fc2032e3beaf79b15317a3f40fd"
            static let AccuracyLevel = "11"
            static let RadiusDistance = "20"
            static let PerPageQuantity = "24"
            static let ResponseFormat = "json"
            static let DisableJSONCallback = "1" /* 1 means "yes" */
            static let SearchPhotosMethod = "flickr.photos.search"
            static let MediumURL = "url_m"
            static let UseSafeSearch = "1"

        }
        
        // MARK: Flickr Response Keys
        struct FlickrResponseKeys {
            static let Status = "stat"
            static let Photos = "photos"
            static let Photo = "photo"
            static let Title = "title"
            static let MediumURL = "url_m"
        }
        
        // MARK: Flickr Response Values
        struct FlickrResponseValues {
            static let OKStatus = "ok"
        }
    }
}
