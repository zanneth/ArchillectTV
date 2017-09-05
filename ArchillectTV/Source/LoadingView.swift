//
//  LoadingView.swift
//  ArchillectTV
//
//  Created by Charles Magahern on 10/25/15.
//

import Darwin
import Foundation
import UIKit

let π = CGFloat.pi

class LoadingView: UIView {
    fileprivate var _outerRingView:  KSIRingView = KSIRingView()
    fileprivate var _middleRingView: KSIRingView = KSIRingView()
    fileprivate var _innerRingView:  KSIRingView = KSIRingView()
    fileprivate var _loadingLabel:   UILabel = UILabel()
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        let segmentsWidth: CGFloat = 20.0
        let ringsColor = UIColor.white
        
        let outerPattern = KSIMutableRingPattern(color: ringsColor, segmentLength: π/2.0, segmentsCount: 2)
        outerPattern?.segmentIntervalRadians = π
        outerPattern?.segmentWidth = segmentsWidth
        _outerRingView.addRingPattern(outerPattern)
        _outerRingView.backgroundColor = UIColor.clear
        
        let middlePattern = KSIMutableRingPattern(color: ringsColor, segmentLength: π/4.5, segmentsCount: 4)
        middlePattern?.segmentIntervalRadians = π/2.0
        middlePattern?.segmentWidth = segmentsWidth
        _middleRingView.addRingPattern(middlePattern)
        _middleRingView.backgroundColor = UIColor.clear
        
        let innerPattern = KSIMutableRingPattern(color: ringsColor, segmentLength: π/3.0, segmentsCount: 3)
        innerPattern?.segmentIntervalRadians = π/1.5
        innerPattern?.segmentWidth = segmentsWidth
        _innerRingView.addRingPattern(innerPattern)
        _innerRingView.backgroundColor = UIColor.clear
        
        _loadingLabel.font = UIFont(name: "Montserrat-Bold", size: 52.0)
        _loadingLabel.text = "LOADING..."
        _loadingLabel.textColor = UIColor.white
        
        self.addSubview(_outerRingView)
        self.addSubview(_middleRingView)
        self.addSubview(_innerRingView)
        self.addSubview(_loadingLabel)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("unsupported")
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        let bounds = self.bounds
        let ringsSpacing: CGFloat = 50.0
        
        let outerRingSize = CGSize(width: bounds.size.width / 1.5, height: bounds.size.height / 1.5)
        let outerRingFrame = CGRect(
            x: rint(bounds.size.width / 2.0 - outerRingSize.width / 2.0),
            y: rint(bounds.size.height / 2.0 - outerRingSize.height / 2.0),
            width: outerRingSize.width,
            height: outerRingSize.height
        )
        _outerRingView.frame = outerRingFrame
        
        let middleRingSize = CGSize(width: outerRingSize.width - ringsSpacing, height: outerRingSize.height - ringsSpacing)
        let middleRingFrame = CGRect(
            x: rint(bounds.size.width / 2.0 - middleRingSize.width / 2.0),
            y: rint(bounds.size.height / 2.0 - middleRingSize.height / 2.0),
            width: middleRingSize.width,
            height: middleRingSize.height
        )
        _middleRingView.frame = middleRingFrame
        
        let innerRingSize = CGSize(width: middleRingSize.width - ringsSpacing, height: middleRingSize.height - ringsSpacing)
        let innerRingFrame = CGRect(
            x: rint(bounds.size.width / 2.0 - innerRingSize.width / 2.0),
            y: rint(bounds.size.height / 2.0 - innerRingSize.height / 2.0),
            width: innerRingSize.width,
            height: innerRingSize.height
        )
        _innerRingView.frame = innerRingFrame
        
        let loadingLabelSize = _loadingLabel.sizeThatFits(bounds.size)
        let loadingLabelFrame = CGRect(
            x: rint(bounds.size.width / 2.0 - loadingLabelSize.width / 2.0),
            y: rint(bounds.size.height / 2.0 - loadingLabelSize.height / 2.0),
            width: loadingLabelSize.width,
            height: loadingLabelSize.height
        )
        _loadingLabel.frame = loadingLabelFrame
    }
    
    func beginAnimating()
    {
        let duration: TimeInterval = 20.0
        
        let clockwiseAnim = CABasicAnimation(keyPath: "transform.rotation")
        clockwiseAnim.fromValue = 0.0
        clockwiseAnim.toValue = 2.0 * π
        clockwiseAnim.duration = duration
        clockwiseAnim.repeatCount = Float.infinity
        
        let counterClockwiseAnim = CABasicAnimation(keyPath: "transform.rotation")
        counterClockwiseAnim.fromValue = 2.0 * π
        counterClockwiseAnim.toValue = 0.0
        counterClockwiseAnim.duration = duration
        counterClockwiseAnim.repeatCount = Float.infinity
        
        _outerRingView.layer.add(clockwiseAnim, forKey: "")
        _middleRingView.layer.add(counterClockwiseAnim, forKey: "")
        _innerRingView.layer.add(clockwiseAnim, forKey: "")
    }
    
    func stopAnimating()
    {
        _outerRingView.layer.removeAllAnimations()
        _middleRingView.layer.removeAllAnimations()
        _innerRingView.layer.removeAllAnimations()
    }
}
