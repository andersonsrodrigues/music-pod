//
//  LoadingView.swift
//  On the map
//
//  Created by Anderson Rodrigues on 14/02/2020.
//  Copyright © 2020 Anderson Rodrigues. All rights reserved.
//

import UIKit

class LoadingView: UIView {
    
    var activityView: UIView!
    var targetView: UIView!
    
    required init(view: UIView) {
        super.init(frame: CGRect())
        targetView = view
        activityView = UIView(frame: targetView.frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func activityIndicator() -> UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView()
        
        activityIndicator.frame.origin.x = 20.0
        activityIndicator.frame.origin.y = 20.0
        activityIndicator.color = .darkGray
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        
        return activityIndicator
    }
    
    private func textLabel() -> UILabel {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 180, height: 40))
        
        label.text = "Please wait..."
        label.textColor = .black
        
        return label
    }
    
    private func loadingView() -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 60))
        let activity = activityIndicator()
        let text = textLabel()
        
        view.addSubview(text)
        view.addSubview(activity)
        
        text.translatesAutoresizingMaskIntoConstraints = false
        activity.translatesAutoresizingMaskIntoConstraints = false
        
        let centerX = NSLayoutConstraint(item: text, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)
        let centerY = NSLayoutConstraint(item: text, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0)
        
        let activityCenterY = NSLayoutConstraint(item: activity, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0)
        let activityMarginX = NSLayoutConstraint(item: activity, attribute: .trailing, relatedBy: .equal, toItem: text, attribute: .leading, multiplier: 1, constant: -10)
        
        view.addConstraints([centerX, centerY, activityCenterY, activityMarginX])
            
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        
        return view
    }
    
    func showActivityView() {
        let loading = loadingView()
        
        activityView.addSubview(loading)
        
        loading.translatesAutoresizingMaskIntoConstraints = false

        let centerX = NSLayoutConstraint(item: loading, attribute: .centerX, relatedBy: .equal, toItem: activityView, attribute: .centerX, multiplier: 1, constant: 0)
        let centerY = NSLayoutConstraint(item: loading, attribute: .centerY, relatedBy: .equal, toItem: activityView, attribute: .centerY, multiplier: 1, constant: 0)
        let width = NSLayoutConstraint(item: loading, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 200)
        let height = NSLayoutConstraint(item: loading, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 60)

        activityView.addConstraints([centerX, centerY, width, height])
        activityView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.45)
        
        targetView.addSubview(activityView)
        
        activityView.translatesAutoresizingMaskIntoConstraints = false
        
        let top = NSLayoutConstraint(item: activityView!, attribute: .topMargin, relatedBy: .equal, toItem: targetView, attribute: .topMargin, multiplier: 1, constant: 0)
        let bottom = NSLayoutConstraint(item: activityView!, attribute: .bottomMargin, relatedBy: .equal, toItem: targetView, attribute: .bottomMargin, multiplier: 1, constant: 0)
        let left = NSLayoutConstraint(item: activityView!, attribute: .leading, relatedBy: .equal, toItem: targetView, attribute: .leading, multiplier: 1, constant: 0)
        let right = NSLayoutConstraint(item: activityView!, attribute: .trailing, relatedBy: .equal, toItem: targetView, attribute: .trailing, multiplier: 1, constant: 0)
        
        targetView.addConstraints([top, bottom, left, right])
    }
    
    func hideActivityView() {
        activityView.removeFromSuperview()
    }
}
