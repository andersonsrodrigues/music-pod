//
//  PlaylistCollectionViewCell.swift
//  MusicPod
//
//  Created by Anderson Rodrigues on 18/03/2020.
//  Copyright © 2020 Anderson Rodrigues. All rights reserved.
//

import UIKit

class PlaylistCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var coverImage: UIImageView!
    
    var activityViewImage = UIActivityIndicatorView()
    var viewActivityCover = UIView()
    
    override func awakeFromNib() {
        
    }
    
    func addLoadingCover() {
        activityViewImage.frame = frame
        activityViewImage.center = center
        activityViewImage.hidesWhenStopped = true
        
        viewActivityCover.frame = frame
        viewActivityCover.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        viewActivityCover.alpha = 0.6
        viewActivityCover.addSubview(activityViewImage)
        
        coverImage.addSubview(viewActivityCover)
    }
    
    func removeLoadingCover() {
        viewActivityCover.removeFromSuperview()
    }
}
