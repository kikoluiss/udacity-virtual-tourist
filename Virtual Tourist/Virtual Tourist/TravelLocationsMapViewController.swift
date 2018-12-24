//
//  TravelLocationsMapViewController.swift
//  Virtual Tourist
//
//  Created by Kiko Santos on 11/12/18.
//  Copyright © 2018 Kiko Santos. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelLocationsMapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var removeAlertLabel: UILabel!
    @IBOutlet weak var editPinsButton: UIBarButtonItem!
    
    var flgEditPins = false

    var dataController: DataController!

    var fetchedResultsController: NSFetchedResultsController<Pin>!
    
    var selectedPin: Pin!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self;
        let uilpgr = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotation(gestureRecognizer:)))
        uilpgr.minimumPressDuration = 2.0
        
        mapView.addGestureRecognizer(uilpgr)
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "OK", style: .plain, target: nil, action: nil)
        
        setupFetchedResultsController()
        
        guard let pins = fetchedResultsController.fetchedObjects else {
            return
        }
        
        for pin in pins {
            self.mapView.addAnnotation(pin)
        }

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFetchedResultsController()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
    @objc func addAnnotation(gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state == UIGestureRecognizer.State.began {
            let touchPoint = gestureRecognizer.location(in: mapView)
            let coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            
            let pin = Pin(context: dataController.viewContext)
            pin.latitude = coordinate.latitude as NSNumber
            pin.longitude = coordinate.longitude as NSNumber
            pin.creationDate = Date()
            try? dataController.viewContext.save()
        }
    }
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "pins")
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    @IBAction func editPins(_ sender: Any) {
        if flgEditPins {
            flgEditPins = false
            editPinsButton.title = "Edit"
            removeAlertLabel.isHidden = true
        } else {
            flgEditPins = true
            editPinsButton.title = "Ok"
            removeAlertLabel.isHidden = false
        }
    }
    
    // -------------------------------------------------------------------------
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? PhotoAlbumViewController {
            vc.selectedPin = selectedPin
            vc.dataController = dataController
        }
    }

}

extension TravelLocationsMapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        if let coordinate = view.annotation?.coordinate {
            let pins = self.fetchedResultsController.fetchedObjects?.filter { (pin) -> Bool in
                if let latitude = pin.latitude, let longitude = pin.longitude {
                    return CLLocationDegrees(latitude.doubleValue) == coordinate.latitude &&
                    CLLocationDegrees(longitude.doubleValue) == coordinate.longitude
                }
                return false
            }

            mapView.deselectAnnotation(view as? MKAnnotation, animated: false)

            if let pins = pins {
                selectedPin = pins[0]
                if flgEditPins {
                    mapView.removeAnnotation(selectedPin)
                    dataController.viewContext.delete(selectedPin)
                    try? dataController.viewContext.save()
                } else {
                    self.performSegue(withIdentifier: "SegueToPhotoAlbum", sender: self)
                }
            }
        }
    }
}

extension TravelLocationsMapViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        guard let pin = anObject as? Pin else {
            preconditionFailure("All changes observed in the map view controller should be for Point instances")
        }
        
        switch type {
        case .insert:
            mapView.addAnnotation(pin)
            
        case .delete:
            mapView.removeAnnotation(pin)
            
        case .update:
            mapView.removeAnnotation(pin)
            mapView.addAnnotation(pin)
            
        case .move:
            // N.B. The fetched results controller was set up with a single sort descriptor that produced a consistent ordering for its fetched Point instances.
            fatalError("How did we move a Point? We have a stable sort.")
        }
    }
    
}
