//
//  TrackTableViewCell.swift
//  MusicPod
//
//  Created by Anderson Rodrigues on 20/03/2020.
//  Copyright © 2020 Anderson Rodrigues. All rights reserved.
//

import UIKit

class TrackTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var loadingActivity: UIActivityIndicatorView!
    @IBOutlet weak var audioBarsView: UIView!
    
    var numBars = 5
    var barSpace = CGFloat(3)
    var barWidth = CGFloat(3)
    var barHeight = CGFloat(2)
    var maxBarHeight = CGFloat(20)
    var arrayBars = [UIView]()
    var timer = Timer()
    let timerSpeed = 0.20
    
    override func awakeFromNib() {
        configCell()
        configAudioBars()
    }
    
    private func configCell() {
        nameLabel.font = UIFont.systemFont(ofSize: 17.0, weight: .semibold)
        artistNameLabel.font = UIFont.systemFont(ofSize: 13.0, weight: .light)
        
        loadingActivity.hidesWhenStopped = true
        loadingActivity.style = .medium
        loadingActivity.color = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        selectionStyle = .none
        backgroundColor = #colorLiteral(red: 0.145080179, green: 0.1451074183, blue: 0.1450739205, alpha: 1)
    }
    
    func available() {
        nameLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        artistNameLabel.textColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
    }
    
    func notAvailable() {
        nameLabel.textColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        artistNameLabel.textColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
    }
    
    // MARK: - Activity Animation
    
    func showLoading() {
        loadingActivity.startAnimating()
    }
    
    func hideLoading() {
        loadingActivity.stopAnimating()
    }
    
    // MARK: - Audio Animation
    
    private func configAudioBars() {
        audioBarsView.isHidden = true
        audioBarsView.backgroundColor = #colorLiteral(red: 0.145080179, green: 0.1451074183, blue: 0.1450739205, alpha: 1)
        
        for i in 0...numBars - 1 {
            let bar = UIView()
            if i == 0 {
                bar.frame = CGRect(x: 5, y: audioBarsView.frame.origin.y, width: barWidth, height: barHeight)
            } else {
                let posX = (CGFloat(barSpace) * CGFloat(i)) + (CGFloat(barWidth) * CGFloat(i) + 5)
                bar.frame = CGRect(x: posX, y: audioBarsView.frame.origin.y, width: barWidth, height: barHeight)
            }
            
            bar.backgroundColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
            
            audioBarsView.addSubview(bar)
            arrayBars.append(bar)
        }
        
        audioBarsView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2) * CGFloat(2.0))
    }
    
    func startAudioAnimation() {
        audioBarsView.isHidden = false
        timer = Timer.scheduledTimer(timeInterval: timerSpeed, target: self, selector: #selector(setupAudioBarsAnimation), userInfo: nil, repeats: true)
    }
    
    func stopAudioAnimation() {
        audioBarsView.isHidden = true
        timer.invalidate()
    }
    
    @objc private func setupAudioBarsAnimation() {
        var i = 0
        
        UIView.animate(withDuration: 0.35) {
            for bar in self.arrayBars {
                var rect = bar.frame
                rect.size.height = CGFloat(arc4random_uniform(UInt32(self.maxBarHeight)))
                bar.frame = rect
                i += 1
            }
        }
    }
}
