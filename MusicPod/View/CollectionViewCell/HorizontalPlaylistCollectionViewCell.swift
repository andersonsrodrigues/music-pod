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
    
    var displayedName: Home.DisplayedEntry? {
        didSet {
            nameLabel.text = displayedName?.name
            coverImage.image = displayedName?.cover
        }
    }

}
