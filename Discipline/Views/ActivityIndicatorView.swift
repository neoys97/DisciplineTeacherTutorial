//
//  ActivityIndicatorView.swift
//  Discipline
//
//  Created by Neo Yi Siang on 5/8/2020.
//  Copyright © 2020 Neo Yi Siang. All rights reserved.
//

import UIKit
import Foundation

class ActivityIndicatorView
{
    var view: UIView!

    var activityIndicator: UIActivityIndicatorView!

    var title: String!

    init(title: String?, center: CGPoint, width: CGFloat = 200.0, height: CGFloat = 50.0)
    {
        let nWidth = title != nil ? width : 50.0
        
        let x = center.x - nWidth/2.0
        let y = center.y - height/2.0

        self.view = UIView(frame: CGRect(x: x, y: y, width: nWidth, height: height))
        self.view.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.3)
        self.view.layer.cornerRadius = 10

        self.activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        self.activityIndicator.color = UIColor.black
        self.activityIndicator.hidesWhenStopped = false
        self.view.addSubview(self.activityIndicator)
        
        if let title = title {
            let titleLabel = UILabel(frame: CGRect(x: 60, y: 0, width: 200, height: 50))
            titleLabel.text = title
            titleLabel.textColor = UIColor.black
            self.view.addSubview(titleLabel)
        }
        
        self.view.isHidden = true
    }

    func getViewActivityIndicator() -> UIView {
        return self.view
    }

    func startAnimating() {
        self.view.isHidden = false
        self.activityIndicator.startAnimating()
    }

    func stopAnimating() {
        self.activityIndicator.stopAnimating()
        self.view.isHidden = true
    }
}
