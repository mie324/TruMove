//
//  SummaryCollectionViewCell.swift
//  TruMove
//
//  Created by Ellen Wang on 2019/4/1.
//  Copyright © 2019 ece1778. All rights reserved.
//

import UIKit
import expanding_collection

class SummaryCollectionViewCell: BasePageCollectionCell {

  
    @IBOutlet var backgroundImageView: UIImageView!
    
    @IBOutlet var customTitle: UILabel!
    
    @IBOutlet weak var userScoreLabel: UILabel!
    
    @IBOutlet weak var scoreNameLabel: UILabel!
    
    @IBOutlet weak var standardValueLabel: UILabel!
    @IBOutlet var conciseAdviceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        customTitle.layer.shadowRadius = 2
        customTitle.layer.shadowOffset = CGSize(width: 0, height: 3)
        customTitle.layer.shadowOpacity = 0.2
    }
}
