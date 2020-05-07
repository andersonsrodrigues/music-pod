//
//  SearchResultTableViewCell.swift
//  MusicPod
//
//  Created by Anderson Rodrigues on 22/03/2020.
//  Copyright © 2020 Anderson Rodrigues. All rights reserved.
//

import UIKit

class SearchResultTableViewCell: UITableViewCell {
    
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    
    var activityViewImage = UIActivityIndicatorView()
    var viewActivityCover = UIView()
    
    override func awakeFromNib() {
        addLoadingCover()
        
        setupCell()
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
    
    private func setupCell() {
        nameLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        nameLabel.font = UIFont.systemFont(ofSize: 17.0, weight: .semibold)
        
        typeLabel.textColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        typeLabel.font = UIFont.systemFont(ofSize: 13.0, weight: .light)
        
        selectionStyle = .none
        backgroundColor = #colorLiteral(red: 0.145080179, green: 0.1451074183, blue: 0.1450739205, alpha: 1)
    }
}
