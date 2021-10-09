//
//  LibraryTableViewCell.swift
//  MusicPod
//
//  Created by Anderson Rodrigues on 20/03/2020.
//  Copyright © 2020 Anderson Rodrigues. All rights reserved.
//

import UIKit

class LibraryTableViewCell: UITableViewCell {
    
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var subNameLabel: UILabel!
    
    var activityViewImage = UIActivityIndicatorView()
    var viewActivityCover = UIView()
    
    override func awakeFromNib() {
        addLoadingCover()
        
        configCell()
    }
    
    func addLoadingCover() {
        activityViewImage.frame = coverImage.frame
        activityViewImage.hidesWhenStopped = true
        
        viewActivityCover.frame = coverImage.frame
        viewActivityCover.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        viewActivityCover.alpha = 0.7
        viewActivityCover.addSubview(activityViewImage)
        
        coverImage.addSubview(viewActivityCover)
    }
    
    func removeLoadingCover() {
        viewActivityCover.removeFromSuperview()
    }
    
    func configCell() {
        nameLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        nameLabel.font = UIFont.systemFont(ofSize: 17.0, weight: .semibold)
        
        subNameLabel.textColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        subNameLabel.font = UIFont.systemFont(ofSize: 14.0, weight: .light)
        subNameLabel.numberOfLines = 2
        
        selectionStyle = .none
        backgroundColor = #colorLiteral(red: 0.145080179, green: 0.1451074183, blue: 0.1450739205, alpha: 1)
    }
}
