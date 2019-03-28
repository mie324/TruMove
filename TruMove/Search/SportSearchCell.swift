//
//  SportSearchCell.swift
//  groupproject
//
//  Created by Ellen Wang on 2019/3/1.
//  Copyright © 2019 ellen. All rights reserved.
//

import UIKit

class SportSearchCell: UITableViewCell {
    
    @IBOutlet weak var sportImageView: UIImageView!
    func setImage(image: UIImage){
        sportImageView.image = image
    }

}

