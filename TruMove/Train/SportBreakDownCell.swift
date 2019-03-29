//
//  SportBreakDownCell.swift
//  TruMove
//
//  Created by Ellen Wang on 2019/3/27.
//  Copyright © 2019 ece1778. All rights reserved.
//


import UIKit
import FoldingCell

class SportBreakDownCell: FoldingCell {
    

    @IBOutlet weak var moveNameLabel: UILabel!

    @IBOutlet weak var bannerImageView: UIImageView!
    
    @IBOutlet weak var instructionImageView: UIImageView!
    
    
    @IBOutlet weak var firstInstructionLabel: UILabel!
    
    @IBOutlet weak var secondInstructionLabel: UILabel!
    
    @IBOutlet weak var thirdInstructionLabel: UILabel!
    override func awakeFromNib() {
        foregroundView.layer.cornerRadius = 10
        foregroundView.layer.masksToBounds = true
        super.awakeFromNib()
    }
    
    override func animationDuration(_ itemIndex: NSInteger, type _: FoldingCell.AnimationType) -> TimeInterval {
        let durations = [0.26, 0.2, 0.2]
        return durations[itemIndex]
    }
    
    func setUp(moveName: String, bannerImage: UIImage, insImage: UIImage, fInstruct: String, sInstruct: String, tInstruct: String){
        moveNameLabel.text = moveName
        self.bannerImageView.image = bannerImage
        self.instructionImageView.image = insImage
        firstInstructionLabel.text = fInstruct
        
        secondInstructionLabel.text = sInstruct
        
        thirdInstructionLabel.text = tInstruct
      
    }
    
    
}
