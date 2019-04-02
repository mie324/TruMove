//
//  CountdownController.swift
//  TruMove
//
//  Created by Ellen Wang on 2019/4/2.
//  Copyright © 2019 ece1778. All rights reserved.
//

import UIKit

class CountdownController : UIViewController {
    
   
    @IBOutlet weak var countdownLabel: UILabel!
    
    var seconds = 4
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.counter), userInfo: nil, repeats: true)
    }
    
    @objc func counter(){
        seconds -= 1
        countdownLabel.text = "\(seconds)"
        if seconds == 0 {
            if timer != nil {
                timer?.invalidate()
                timer = nil
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}

