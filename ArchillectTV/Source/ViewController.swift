//
//  ViewController.swift
//  ArchillectTV
//
//  Created by Charles Magahern on 10/24/15.
//

import UIKit

class ViewController: UIViewController, ArchillectControllerDelegate {
    private var _archillectController:  ArchillectController = ArchillectController()
    private var _backgroundImageView:   UIImageView = UIImageView()
    private var _foregroundImageView:   UIImageView = UIImageView()
    private var _urlSession:            NSURLSession?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        _backgroundImageView.contentMode = .ScaleAspectFill
        self.view.addSubview(_backgroundImageView)
        
        _foregroundImageView.contentMode = .ScaleAspectFit
        self.view.addSubview(_foregroundImageView)
        
        _urlSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        
        _archillectController.delegate = self
        _archillectController.connect()
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        
        UIApplication.sharedApplication().idleTimerDisabled = true
        _backgroundImageView.startAnimating()
        _foregroundImageView.startAnimating()
    }
    
    override func viewDidDisappear(animated: Bool)
    {
        super.viewDidDisappear(animated)
        
        UIApplication.sharedApplication().idleTimerDisabled = false
        _backgroundImageView.stopAnimating()
        _foregroundImageView.stopAnimating()
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
        let bounds = self.view.bounds
        _backgroundImageView.frame = bounds
        _foregroundImageView.frame = bounds
    }
    
    // MARK: ArchillectControllerDelegate
    
    func archillectControllerDidReceiveNewAsset(controller: ArchillectController, asset: ArchillectAsset)
    {
        _reloadImageViewsWithAsset(asset)
    }
    
    func archillectControllerDidFailToLoad(controller: ArchillectController, error: NSError)
    {
        print("Failed to load: \(error)")
    }
    
    // MARK: Internal
    
    internal func _reloadImageViewsWithAsset(asset: ArchillectAsset)
    {
        let loadTask = _urlSession?.dataTaskWithURL(asset.url, completionHandler: { (imageData: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            if (imageData != nil) {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    let image = UIImage.animatedImageWithAnimatedGIFData(imageData!)
                    self._backgroundImageView.image = image
                    self._foregroundImageView.image = image
                })
            } else {
                print("Error loading asset \(asset). \(error)")
            }
        })
        loadTask?.resume()
    }
}
