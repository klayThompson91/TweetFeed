//
//  CardViews.swift
//  TweetFeed
//
//  Created by Abhay Curam on 4/15/18.
//  Copyright © 2018 Tweeter. All rights reserved.
//

import Foundation
import UIKit

public class CardTableViewCell: UITableViewCell {
    
    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor.white
        self.configureCALayerAsCard()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
}

public class CardView: UIView {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
        self.configureCALayerAsCard()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
}

fileprivate extension UIView {
    
    fileprivate func configureCALayerAsCard() {
        self.layer.cornerRadius = 2
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.35
        self.layer.shadowRadius = 2
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
    }
    
}
