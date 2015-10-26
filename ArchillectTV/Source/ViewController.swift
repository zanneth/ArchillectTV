//
//  ViewController.swift
//  ArchillectTV
//
//  Created by Charles Magahern on 10/24/15.
//

import UIKit

class ViewController: UIViewController, ArchillectControllerDelegate {
    private var _archillectController:  ArchillectController = ArchillectController()
    private var _urlSession:            NSURLSession?
    
    private var _backgroundImageView:   UIImageView = UIImageView()
    private var _foregroundImageView:   UIImageView = UIImageView()
    private var _archillectLabel:       UILabel = UILabel()
    private var _indexLabel:            UILabel = UILabel()
    private var _errorView:             ErrorView?
    
    private static let kChromePadding: CGFloat = 50.0
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.blackColor()
        
        _backgroundImageView.contentMode = .ScaleAspectFill
        self.view.addSubview(_backgroundImageView)
        
        _foregroundImageView.contentMode = .ScaleAspectFit
        self.view.addSubview(_foregroundImageView)
        
        _archillectLabel.text = "ARCHILLECT"
        _archillectLabel.textColor = UIColor.whiteColor()
        _archillectLabel.font = UIFont(name: "Montserrat-Bold", size: 26.0)
        self.view.addSubview(_archillectLabel)
        
        _indexLabel.textColor = UIColor.whiteColor()
        _indexLabel.font = UIFont(name: "SourceCodePro-Regular", size: 18.0)
        self.view.addSubview(_indexLabel)
        
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
        _errorView?.frame = bounds
        
        let archillectLabelSize = _archillectLabel.sizeThatFits(bounds.size)
        let archillectLabelFrame = CGRect(
            x: ViewController.kChromePadding,
            y: bounds.size.height - ViewController.kChromePadding - archillectLabelSize.height,
            width: archillectLabelSize.width,
            height: archillectLabelSize.height
        )
        _archillectLabel.frame = archillectLabelFrame
        
        let indexLabelSize = _indexLabel.sizeThatFits(bounds.size)
        let indexLabelFrame = CGRect(
            x: CGRectGetMaxX(archillectLabelFrame) + 10.0,
            y: rint(archillectLabelFrame.origin.y + archillectLabelSize.height / 2.0 - indexLabelSize.height / 2.0),
            width: indexLabelSize.width,
            height: indexLabelSize.height
        )
        _indexLabel.frame = indexLabelFrame
    }
    
    // MARK: ArchillectControllerDelegate
    
    func archillectControllerDidReceiveNewAsset(controller: ArchillectController, asset: ArchillectAsset)
    {
        _reloadImageViewsWithAsset(asset)
    }
    
    func archillectControllerDidFailToLoad(controller: ArchillectController, error: NSError)
    {
        NSLog("Failed to load: \(error)")
        _setErrorScreenVisible(true)
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
                    self._indexLabel.text = "#\(asset.index)"
                    self.view.setNeedsLayout()
                })
            } else {
                NSLog("Error loading asset \(asset). \(error)")
            }
        })
        loadTask?.resume()
    }
    
    internal func _setErrorScreenVisible(visible: Bool)
    {
        if (visible && _errorView == nil) {
            _errorView = ErrorView(frame: CGRectZero)
            self.view.addSubview(_errorView!)
        }
        
        _errorView?.hidden = !visible
        _archillectLabel.hidden = visible
        _indexLabel.hidden = visible
        _backgroundImageView.hidden = visible
        _foregroundImageView.hidden = visible
        
        self.view.setNeedsLayout()
    }
}
