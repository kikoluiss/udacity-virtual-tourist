//
//  GeneralUtilities.swift
//  Virtual Tourist
//
//  Created by Kiko Santos on 17/12/18.
//  Copyright © 2018 Kiko Santos. All rights reserved.
//

import Foundation
import UIKit

class GeneralUtilities {
    
    func displayError(_ errorString: String, _ viewController: UIViewController) {
        let alert = UIAlertController(title: "Alert", message: errorString, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            switch action.style{
            case .default:
                print("default")
                
            case .cancel:
                print("cancel")
                
            case .destructive:
                print("destructive")
                
            }}))
        viewController.present(alert, animated: true, completion: nil)
    }
    
    func displayConfirmation(_ message: String, _ confirmTitle: String, _ viewController: UIViewController, completionHandlerForConfirmation: @escaping () -> Void) {
        let alert = UIAlertController(title: "Confirmation", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: confirmTitle, style: .default, handler: { action in
            switch action.style{
            case .default:
                print("default")
                completionHandlerForConfirmation()
            case .cancel:
                print("cancel")
                
            case .destructive:
                print("destructive")
                
            }}))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { action in
            switch action.style{
            case .default:
                print("default")
                
            case .cancel:
                print("cancel")
                
            case .destructive:
                print("destructive")
                
            }}))
        viewController.present(alert, animated: true, completion: nil)
    }
    
    class func sharedInstance() -> GeneralUtilities {
        struct Singleton {
            static var sharedInstance = GeneralUtilities()
        }
        return Singleton.sharedInstance
    }
    
}
