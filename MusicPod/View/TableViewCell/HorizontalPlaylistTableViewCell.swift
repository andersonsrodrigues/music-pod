//
//  HorizontalPlaylistTableViewCell.swift
//  MusicPod
//
//  Created by Anderson Rodrigues on 19/03/2020.
//  Copyright © 2020 Anderson Rodrigues. All rights reserved.
//

import UIKit

let reuseHorizontalPlaylistIdentifier = "reuseHorizontalPlaylistCell"

enum ScrollDirection {
    case vertical
    case horizontal
}

class HorizontalPlaylistTableViewCell: UITableViewCell {
    @IBOutlet private weak var collectionView: UICollectionView!
}

extension HorizontalPlaylistTableViewCell {
    var collectionViewOffset: CGFloat {
        get {
            return collectionView.contentOffset.x
        }

        set {
            collectionView.contentOffset.x = newValue
        }
    }
    
    func setCollectionViewDataSourceDelegate<T: UICollectionViewDataSource & UICollectionViewDelegate>(_ dataSourceDelegate: T, forSection section: Int, direction: ScrollDirection) {
        collectionView.delegate = dataSourceDelegate
        collectionView.dataSource = dataSourceDelegate
        collectionView.tag = section
        
        switch direction {
        case .horizontal:
            collectionView.showsHorizontalScrollIndicator = true
        case .vertical:
            collectionView.showsVerticalScrollIndicator = true
        }
        
        collectionView.register(UINib(nibName: "HorizontalPlaylistCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseHorizontalPlaylistIdentifier)
        collectionView.backgroundColor = #colorLiteral(red: 0.145080179, green: 0.1451074183, blue: 0.1450739205, alpha: 1)
        collectionView.setContentOffset(collectionView.contentOffset, animated:false)
        collectionView.reloadData()
    }
}
