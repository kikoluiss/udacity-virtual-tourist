//
//  FlickrConvenience.swift
//  Virtual Tourist
//
//  Created by Kiko Santos on 17/12/18.
//  Copyright © 2018 Kiko Santos. All rights reserved.
//

import Foundation

extension FlickrClient {
    
    func retrievePhotosByLocation(latitude: Double, longitude: Double, completionHandlerForPhotosByLocation: @escaping (_ result: AnyObject?, _ errorString: String?) -> Void) {
        
        let methodParameters: [String: String] = [
            Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.SearchPhotosMethod,
            Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey,
            Constants.FlickrParameterKeys.SafeSearch: Constants.FlickrParameterValues.UseSafeSearch,
            Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL,
            Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat,
            Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback,
            Constants.FlickrParameterKeys.Accuracy: Constants.FlickrParameterValues.AccuracyLevel,
            Constants.FlickrParameterKeys.Radius: Constants.FlickrParameterValues.RadiusDistance,
            Constants.FlickrParameterKeys.PerPage: Constants.FlickrParameterValues.PerPageQuantity,
            Constants.FlickrParameterKeys.Latitude: String(format:"%f", latitude),
            Constants.FlickrParameterKeys.Longitude: String(format:"%f", longitude)
        ]

        let _ = taskForGETMethod(methodParameters) { (results, error) in
            if let error = error {
                completionHandlerForPhotosByLocation(nil, "Failed to Load Photos: \(error.localizedDescription).")
            } else {
                completionHandlerForPhotosByLocation(results, nil)
            }
        }
    }
}
