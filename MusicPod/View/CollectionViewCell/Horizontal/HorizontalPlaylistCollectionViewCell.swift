//
//  HorizontalPlaylistCollectionViewCell.swift
//  MusicPod
//
//  Created by Anderson Rodrigues on 19/03/2020.
//  Copyright © 2020 Anderson Rodrigues. All rights reserved.
//

import UIKit

class HorizontalPlaylistCollectionViewCell: UICollectionViewCell {

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
        nameLabel.font = .systemFont(ofSize: 17.0, weight: .semibold)
        nameLabel.textColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
        
        backgroundColor = #colorLiteral(red: 0.145080179, green: 0.1451074183, blue: 0.1450739205, alpha: 1)
    }
}
