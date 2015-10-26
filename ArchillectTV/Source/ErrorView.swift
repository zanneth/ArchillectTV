//
//  ErrorView.swift
//  ArchillectTV
//
//  Created by Charles Magahern on 10/25/15.
//

import Foundation
import UIKit

class ErrorView: UIView {
    private var _errorImageView:        UIImageView = UIImageView()
    private var _errorTitleLabel:       UILabel = UILabel()
    private var _errorDescriptionLabel: UILabel = UILabel()
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        _errorImageView.image = UIImage(named: "error_symbol")
        self.addSubview(_errorImageView)
        
        _errorTitleLabel.font = UIFont.boldSystemFontOfSize(72.0)
        _errorTitleLabel.text = "失敗"
        _errorTitleLabel.textColor = UIColor.redColor()
        self.addSubview(_errorTitleLabel)
        
        _errorDescriptionLabel.font = UIFont(name: "Montserrat-Regular", size: 24.0)
        _errorDescriptionLabel.text = "Error loading assets from Archillect server."
        _errorDescriptionLabel.textColor = UIColor.whiteColor()
        self.addSubview(_errorDescriptionLabel)
    }

    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        let bounds = self.bounds
        let titleLabelMargin: CGFloat = 20.0
        let titleLabelSize = _errorTitleLabel.sizeThatFits(bounds.size)
        let errorImageSize = _errorImageView.image!.size
        let imageTitleTotalHeight = errorImageSize.height + titleLabelMargin + titleLabelSize.height
        let imageTitleBounds = CGRect(
            x: rint(bounds.size.width / 2.0 - errorImageSize.width / 2.0),
            y: rint(bounds.size.height / 2.0 - imageTitleTotalHeight / 2.0),
            width: errorImageSize.width,
            height: imageTitleTotalHeight
        )
        
        let imageViewFrame = CGRect(
            x: rint(imageTitleBounds.origin.x + (imageTitleBounds.size.width / 2.0 - errorImageSize.width / 2.0)),
            y: imageTitleBounds.origin.y,
            width: rint(errorImageSize.width),
            height: rint(errorImageSize.height)
        )
        _errorImageView.frame = imageViewFrame
        
        let titleLabelFrame = CGRect(
            x: rint(imageTitleBounds.origin.x + (imageTitleBounds.size.width / 2.0 - titleLabelSize.width / 2.0)),
            y: CGRectGetMaxY(imageViewFrame) + titleLabelMargin,
            width: titleLabelSize.width,
            height: titleLabelSize.height
        )
        _errorTitleLabel.frame = titleLabelFrame
        
        let errorDescriptionLabelSize = _errorDescriptionLabel.sizeThatFits(bounds.size)
        let errorDescriptionLabelFrame = CGRect(
            x: rint(bounds.size.width / 2.0 - errorDescriptionLabelSize.width / 2.0),
            y: rint(CGRectGetMaxY(titleLabelFrame) + (titleLabelMargin * 2.0)),
            width: errorDescriptionLabelSize.width,
            height: errorDescriptionLabelSize.height
        )
        _errorDescriptionLabel.frame = errorDescriptionLabelFrame
    }
}
