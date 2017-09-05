//
//  ViewController.swift
//  ArchillectTV
//
//  Created by Charles Magahern on 10/24/15.
//

import UIKit

class ViewController: UIViewController, ArchillectControllerDelegate {
    fileprivate var _archillectController:  ArchillectController = ArchillectController()
    fileprivate var _urlSession:            URLSession?
    
    fileprivate var _backgroundImageView:   UIImageView = UIImageView()
    fileprivate var _foregroundImageView:   UIImageView = UIImageView()
    fileprivate var _archillectLabel:       UILabel = UILabel()
    fileprivate var _indexLabel:            UILabel = UILabel()
    fileprivate var _errorView:             ErrorView?
    fileprivate var _loadingView:           LoadingView?
    
    fileprivate static let kChromePadding: CGFloat = 50.0
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.black
        
        _backgroundImageView.contentMode = .scaleAspectFill
        self.view.addSubview(_backgroundImageView)
        
        _foregroundImageView.contentMode = .scaleAspectFit
        self.view.addSubview(_foregroundImageView)
        
        _archillectLabel.text = "ARCHILLECT"
        _archillectLabel.textColor = UIColor.white
        _archillectLabel.font = UIFont(name: "Montserrat-Bold", size: 26.0)
        self.view.addSubview(_archillectLabel)
        
        _indexLabel.textColor = UIColor.white
        _indexLabel.font = UIFont(name: "SourceCodePro-Regular", size: 18.0)
        self.view.addSubview(_indexLabel)
        
        _urlSession = URLSession(configuration: URLSessionConfiguration.default)
        
        _archillectController.delegate = self
        _archillectController.connect()
        
        _setLoadingScreenVisible(true)
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        UIApplication.shared.isIdleTimerDisabled = true
        _backgroundImageView.startAnimating()
        _foregroundImageView.startAnimating()
    }
    
    override func viewDidDisappear(_ animated: Bool)
    {
        super.viewDidDisappear(animated)
        
        UIApplication.shared.isIdleTimerDisabled = false
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
        _loadingView?.frame = bounds
        
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
            x: archillectLabelFrame.maxX + 10.0,
            y: rint(archillectLabelFrame.origin.y + archillectLabelSize.height / 2.0 - indexLabelSize.height / 2.0),
            width: indexLabelSize.width,
            height: indexLabelSize.height
        )
        _indexLabel.frame = indexLabelFrame
    }
    
    // MARK: ArchillectControllerDelegate
    
    func archillectControllerDidReceiveNewAsset(_ controller: ArchillectController, asset: ArchillectAsset)
    {
        _reloadImageViewsWithAsset(asset)
    }
    
    func archillectControllerDidFailToLoad(_ controller: ArchillectController, error: ArchillectError)
    {
        NSLog("Failed to load: \(error)")
        
        DispatchQueue.main.async(execute: { () -> Void in
            self._setErrorScreenVisible(true)
        })
    }
    
    // MARK: Internal
    
    internal func _reloadImageViewsWithAsset(_ asset: ArchillectAsset)
    {
        guard let url = asset.url else { return }
        
        let loadTask = _urlSession?.dataTask(with: url, completionHandler: { (imageData: Data?, response: URLResponse?, error: Error?) -> Void in
            if (imageData != nil) {
                DispatchQueue.main.async(execute: { () -> Void in
                    let image = UIImage.animatedImage(withAnimatedGIFData: imageData!)
                    self._backgroundImageView.image = image
                    self._foregroundImageView.image = image
                    self._indexLabel.text = "#\(asset.index)"
                    self._setLoadingScreenVisible(false)
                    self.view.setNeedsLayout()
                })
            } else {
                NSLog("Error loading asset \(asset). \(error ?? ArchillectError(.unknown))")
            }
        })
        loadTask?.resume()
    }
    
    internal func _setErrorScreenVisible(_ visible: Bool)
    {
        if (visible && _errorView == nil) {
            _errorView = ErrorView(frame: CGRect.zero)
            self.view.addSubview(_errorView!)
        }
        
        _errorView?.isHidden = !visible
        _loadingView?.isHidden = visible
        _archillectLabel.isHidden = visible
        _indexLabel.isHidden = visible
        _backgroundImageView.isHidden = visible
        _foregroundImageView.isHidden = visible
        
        self.view.setNeedsLayout()
    }
    
    internal func _setLoadingScreenVisible(_ visible: Bool)
    {
        if (visible && _loadingView == nil) {
            _loadingView = LoadingView(frame: CGRect.zero)
            self.view.addSubview(_loadingView!)
        }
        
        _loadingView?.isHidden = !visible
        _errorView?.isHidden = visible
        _archillectLabel.isHidden = visible
        _indexLabel.isHidden = visible
        _backgroundImageView.isHidden = visible
        _foregroundImageView.isHidden = visible
        
        if (visible) {
            _loadingView?.beginAnimating()
        } else {
            _loadingView?.stopAnimating()
        }
        
        self.view.setNeedsLayout()
    }
}
