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
    @IBOutlet weak var instructionLabel: UILabel!
   
    @IBOutlet weak var reminderLabel: UILabel!
    
    override func awakeFromNib() {
        foregroundView.layer.cornerRadius = 10
        foregroundView.layer.masksToBounds = true

        super.awakeFromNib()
    }
    
    override func animationDuration(_ itemIndex: NSInteger, type _: FoldingCell.AnimationType) -> TimeInterval {
        let durations = [0.26, 0.2, 0.2]
        return durations[itemIndex]
    }
    
    func setUp(moveName: String, bannerImage: UIImage, insImage: UIImage, mainInstruct: [String]){
        moveNameLabel.text = moveName
        self.bannerImageView.image = bannerImage
        self.instructionImageView.image = insImage
       
        self.reminderLabel.text = " Please check the sensor connection and follow the dumbbell.\n"
        
        let bullet = ""
        
        var strings = mainInstruct.map{return bullet + $0}
        
        var attributes = [NSAttributedString.Key: Any]()
        attributes[.font] = UIFont(name: "Georgia", size: 17.0)!
        attributes[.foregroundColor] = UIColor.darkGray
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.headIndent = (bullet as NSString).size(withAttributes: attributes).width
        attributes[.paragraphStyle] = paragraphStyle
        
        let string = strings.joined(separator: "\n")
        instructionLabel.attributedText = NSAttributedString(string: string, attributes: attributes)
      
    }
    
    
}
