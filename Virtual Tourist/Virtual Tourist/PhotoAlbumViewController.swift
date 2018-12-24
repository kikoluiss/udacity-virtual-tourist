//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Kiko Santos on 11/12/18.
//  Copyright © 2018 Kiko Santos. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var PhotoAlbum: UICollectionView!
    @IBOutlet weak var actionButton: UIButton!
        
    var dataController: DataController!
    
    var fetchedResultsController: NSFetchedResultsController<Photo>!

    private var sectionChanges = [(type: NSFetchedResultsChangeType, sectionIndex: Int)]()
    private var itemChanges = [(type: NSFetchedResultsChangeType, indexPath: IndexPath?, newIndexPath: IndexPath?)]()

    var selectedPin: Pin!

    var photosForPin: [[String: AnyObject]]?
    
    var selectedPhotos: [Photo] = [Photo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        PhotoAlbum.allowsMultipleSelection = true
        
        mapView.addAnnotation(selectedPin)
        let viewRegion = MKCoordinateRegion(center: selectedPin.coordinate, latitudinalMeters: 30000, longitudinalMeters: 30000)
        mapView.setRegion(viewRegion, animated: false)
        
        setupFetchedResultsController()
        
        guard let photos = fetchedResultsController.fetchedObjects else {
            return
        }

        if photos.count == 0 {
            self.loadPhotos(latitude: selectedPin.latitude as! Double, longitude: selectedPin.longitude as! Double)
        } else {
            PhotoAlbum.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFetchedResultsController()
        updateButtonLabel()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", selectedPin)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }

    func loadPhotos(latitude: Double, longitude: Double) {
        FlickrClient.sharedInstance().retrievePhotosByLocation(latitude: latitude, longitude: longitude, completionHandlerForPhotosByLocation: { (results, errorString) in
            performUIUpdatesOnMain {
                if let results = results as? [String: AnyObject] {
                    if (results.count > 0) {
                        if let photosResult = results[FlickrClient.Constants.FlickrResponseKeys.Photos] as? [String: AnyObject], let photosArray = photosResult[FlickrClient.Constants.FlickrResponseKeys.Photo] as? [[String: AnyObject]] {
                            if (photosArray.count > 0) {
                                self.photosForPin = photosArray
                                self.PhotoAlbum.reloadData()
                                for photoItem in photosArray {
                                    if let photoURL = photoItem[FlickrClient.Constants.FlickrResponseKeys.MediumURL] as? String {
                                        FlickrClient.sharedInstance().downloadImage(photoURL) { (data, errorString) in
                                            if let data = data {
                                                let photo = Photo(context: self.dataController.viewContext)
                                                photo.creationDate = Date()
                                                photo.pin = self.selectedPin
                                                photo.rawData = data
                                                try? self.dataController.viewContext.save()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                } else {
                    if let errorString = errorString {
                        GeneralUtilities.sharedInstance().displayError(errorString, self)
                    } else {
                        GeneralUtilities.sharedInstance().displayError("Unknown error", self)
                    }
                }
            }
        })

    }

    func updateButtonLabel() {
        if selectedPhotos.count > 0 {
            actionButton.setTitle("Remove Items", for: .normal)
        } else {
            actionButton.setTitle("New Collection", for: .normal)
        }
    }
    
    @IBAction func buttonTapped(_ sender: Any) {
        actionButton.isEnabled = false
        if selectedPhotos.count > 0 {
            for photo in selectedPhotos {
                dataController.viewContext.delete(photo)
            }
            try? dataController.viewContext.save()
            selectedPhotos = [Photo]()
        } else {
            if let photos = fetchedResultsController.fetchedObjects {
                for photo in photos {
                    dataController.viewContext.delete(photo)
                }
                try? dataController.viewContext.save()
                loadPhotos(latitude: selectedPin.coordinate.latitude, longitude: selectedPin.coordinate.longitude)
            }
        }
        updateButtonLabel()
    }
    
}

extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate {

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        sectionChanges.append((type, sectionIndex))
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?)
    {
        itemChanges.append((type, indexPath, newIndexPath))
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>)
    {
        PhotoAlbum.performBatchUpdates({
            
            for change in self.sectionChanges {
                switch change.type {
                case .insert: self.PhotoAlbum.insertSections([change.sectionIndex])
                case .delete: self.PhotoAlbum.deleteSections([change.sectionIndex])
                default: break
                }
            }
            
            for change in self.itemChanges {
                switch change.type {
                case .insert: self.PhotoAlbum.reloadItems(at: [change.newIndexPath!])
                case .delete: self.PhotoAlbum.deleteItems(at: [change.indexPath!])
                case .update: self.PhotoAlbum.reloadItems(at: [change.indexPath!])
                case .move:
                    self.PhotoAlbum.deleteItems(at: [change.indexPath!])
                    self.PhotoAlbum.insertItems(at: [change.newIndexPath!])
                }
            }
            
        }, completion: { finished in
            self.sectionChanges.removeAll()
            self.itemChanges.removeAll()
        })
    }
    
}

extension PhotoAlbumViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width / 3) - 8
        let height = width
        return CGSize(width: width, height: height)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let dataCount = fetchedResultsController.sections?[0].numberOfObjects ?? 0
        let loadCount = photosForPin?.count ?? 0
        if dataCount >= loadCount {
            photosForPin?.removeAll(keepingCapacity: false)
            return dataCount
        }
        return loadCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoAlbumCell", for: indexPath) as! PhotoAlbumCell

        if fetchedResultsController.sections?[0].numberOfObjects ?? -1 > indexPath.row {
            if let photo = fetchedResultsController.fetchedObjects?[indexPath.row], let photoData = photo.rawData {
                cell.imageView.image = UIImage(data: photoData)
            }
        } else {
            cell.imageView.image = nil
            let activityIndicator = UIActivityIndicatorView(style: .gray)
            activityIndicator.frame = CGRect(x: 0, y: 0, width: cell.imageView.bounds.width, height: cell.imageView.bounds.height)
            activityIndicator.hidesWhenStopped = true
            
            cell.imageView.addSubview(activityIndicator)
            
            activityIndicator.startAnimating()
        }
        
        return cell;
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let photo = fetchedResultsController.fetchedObjects?[indexPath.row] {
            selectedPhotos.append(photo)
            updateButtonLabel()
        }
        
        if let cell = collectionView.cellForItem(at: indexPath) {
            cell.layer.borderWidth = 4.0
            cell.layer.borderColor = UIColor.gray.cgColor

            let cellRect = cell.bounds
            let cellCoverView = UIView(frame: cellRect)
            cellCoverView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            cellCoverView.tag = indexPath.row
            cell.contentView.addSubview(cellCoverView)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {

        if let photo = fetchedResultsController.fetchedObjects?[indexPath.row] {
            selectedPhotos.removeAll(where: { $0 == photo })
            updateButtonLabel()
        }

        if let cell = collectionView.cellForItem(at: indexPath) {
            cell.layer.borderWidth = 0.0
            cell.layer.borderColor = UIColor.white.cgColor
            
            for cellCoverview in cell.contentView.subviews {
                if cellCoverview.tag == indexPath.row {
                    cellCoverview.removeFromSuperview()
                }
            }
        }
    }
    
}
