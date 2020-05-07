//
//  CategoryCollectionViewCell.swift
//  MusicPod
//
//  Created by Anderson Rodrigues on 18/03/2020.
//  Copyright © 2020 Anderson Rodrigues. All rights reserved.
//

import UIKit

class CategoryCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    var activityViewImage = UIActivityIndicatorView()
    var viewActivityCover = UIView()
    
    override func awakeFromNib() {
        setupLayout()
    }
    
    func addLoadingCover() {
        activityViewImage.frame = frame
        activityViewImage.center = center
        activityViewImage.hidesWhenStopped = true
        
        viewActivityCover.frame = frame
        viewActivityCover.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        viewActivityCover.alpha = 0.7
        viewActivityCover.addSubview(activityViewImage)
        
        coverImage.addSubview(viewActivityCover)
    }
    
    func removeLoadingCover() {
        viewActivityCover.removeFromSuperview()
    }
    
    func setupLayout() {
        nameLabel.font = .systemFont(ofSize: 17.0, weight: .regular)
        nameLabel.textAlignment = .center
        nameLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    }
}
