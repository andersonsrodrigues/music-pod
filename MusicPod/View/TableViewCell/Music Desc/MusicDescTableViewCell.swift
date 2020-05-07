//
//  MusicDescTableViewCell.swift
//  MusicPod
//
//  Created by Anderson Rodrigues on 12/04/2020.
//  Copyright © 2020 Anderson Rodrigues. All rights reserved.
//

import UIKit

class MusicDescTableViewCell: UITableViewCell {
    
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descTextView: UITextView!
    
    var activityViewImage = UIActivityIndicatorView()
    var viewActivityCover = UIView()
    
    override func awakeFromNib() {
        configCell()
    }
    
    func showLoadingCover() {
        activityViewImage.frame = coverImage.frame
        activityViewImage.style = .medium
        activityViewImage.hidesWhenStopped = true
        
        viewActivityCover.frame = coverImage.frame
        viewActivityCover.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        viewActivityCover.alpha = 0.7
        viewActivityCover.addSubview(activityViewImage)
        
        activityViewImage.center = viewActivityCover.center
        
        activityViewImage.startAnimating()
        
        coverImage.addSubview(viewActivityCover)
    }
    
    func hideLoadingCover() {
        activityViewImage.stopAnimating()
        viewActivityCover.removeFromSuperview()
    }
    
    func configCell() {
        nameLabel.font = UIFont.systemFont(ofSize: 20.0, weight: .semibold)
        nameLabel.numberOfLines = 3
        nameLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        descTextView.font = UIFont.systemFont(ofSize: 13.0, weight: .light)
        descTextView.textColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
        descTextView.backgroundColor = #colorLiteral(red: 0.145080179, green: 0.1451074183, blue: 0.1450739205, alpha: 1)
        descTextView.isEditable = false
        descTextView.isSelectable = false
        descTextView.textContainer.lineFragmentPadding = 0
        descTextView.textContainerInset = .zero
        
        selectionStyle = .none
        backgroundColor = #colorLiteral(red: 0.145080179, green: 0.1451074183, blue: 0.1450739205, alpha: 1)
    }
}
