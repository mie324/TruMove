//
//  GuidelineViewController.swift
//  TruMove
//
//  Created by Damon on 2019-03-30.
//  Copyright © 2019 ece1778. All rights reserved.
//

import UIKit

class GuidelineViewController: UIViewController {
    
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var okButton: UIButton!
    
    let alertViewGrayColor = UIColor(red: 224.0/255.0, green: 224.0/255.0, blue: 224.0/255.0, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        animateView()
    }
    
    func setUpView() {
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
    }
    
    func animateView() {
        alertView.alpha = 0;
        self.alertView.frame.origin.y = self.alertView.frame.origin.y + 50
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.alertView.alpha = 1.0;
            self.alertView.frame.origin.y = self.alertView.frame.origin.y - 50
        })
    }
    
    @IBAction func okButtonTabbed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
