//
//  DataAnalysisController.swift
//  groupproject
//
//  Created by Ellen Wang on 2019/3/2.
//  Copyright © 2019 ellen. All rights reserved.
//

import UIKit
import Firebase

class DataAnalysisController: UIViewController {
    
    //MARK: LABEL & TEXTFIELD & IMAGE SET UP
    
    var bannerImageView: UIImageView = {
        let biv = UIImageView()
        biv.contentMode = .scaleAspectFit
        biv.image = UIImage(named: "BicepsCurl_Banner.png")
        return biv
    }()
    
    
    var averValueLabel: UILabel = {
        let vlb = UILabel()
        vlb.backgroundColor = .white
        vlb.text = "0.0"
        vlb.font = UIFont(name: "HelveticaNeue-medium", size: CGFloat(26))
        vlb.textAlignment = .center
        return vlb
    }()
    
    var simage = UIImage(named: "Feedback_CircleGreen.png")
    
    var circleImageView: UIImageView = {
        let civ = UIImageView()
        civ.contentMode = .scaleAspectFit
        return civ
    }()
    
    var commentLabel: UILabel = {
        let lb = UILabel()
        lb.backgroundColor = .white
        lb.font = UIFont.boldSystemFont(ofSize: 20)
        lb.textColor = UIColor.gray
        lb.textAlignment = .center
        lb.text = "Average lateral acceleration"
        return lb
    }()
    
    var starttime = 0.0
    var yArray = Array<Double>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = false
        navigationItem.title = "TruMove"
        
        view.backgroundColor = .white
        
        setupPage()
        calculateAvg()
        
    }
    
    fileprivate func setupPage(){
        
        view.addSubview(bannerImageView)
        underNav(newView: bannerImageView)
        
        //        view.addSubview(averValueLabel)
        //        averValueLabel.anchor(top: bannerImageView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: circleImageView.frame.width, height: circleImageView.frame.height)
        
        circleImageView.image = simage
        view.addSubview(circleImageView)
        circleImageView.anchor(top: bannerImageView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: circleImageView.frame.width, height: circleImageView.frame.height)
        
        
        circleImageView.addSubview(averValueLabel)
        averValueLabel.anchor(top: bannerImageView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 90, paddingLeft: 130, paddingBottom: 50, paddingRight: 130, width: circleImageView.frame.width, height: circleImageView.frame.height)
        
        
        view.addSubview(commentLabel)
        commentLabel.anchor(top: circleImageView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 50)
        
        
        
    }
    
    func calculateAvg() {
        let cnt = self.yArray.count
        var total = 0.0
        for data in yArray {
            total = total + data
        }
        let aver = total / Double(cnt)
        self.averValueLabel.text = String(aver)
        if (aver <= 0){
            simage = UIImage(named: "Feedback_CircleRed")
        }
    }
    
    fileprivate func underNav(newView: UIView){
        newView.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 11.0, *) {
            let guide = self.view.safeAreaLayoutGuide
            newView.trailingAnchor.constraint(equalTo: guide.trailingAnchor).isActive = true
            newView.leadingAnchor.constraint(equalTo: guide.leadingAnchor).isActive = true
            newView.topAnchor.constraint(equalTo: guide.topAnchor).isActive = true
            newView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        } else {
            NSLayoutConstraint(item: newView,
                               attribute: .top,
                               relatedBy: .equal,
                               toItem: view, attribute: .top,
                               multiplier: 1.0, constant: 0).isActive = true
            NSLayoutConstraint(item: newView,
                               attribute: .leading,
                               relatedBy: .equal, toItem: view,
                               attribute: .leading,
                               multiplier: 1.0,
                               constant: 0).isActive = true
            NSLayoutConstraint(item: newView, attribute: .trailing,
                               relatedBy: .equal,
                               toItem: view,
                               attribute: .trailing,
                               multiplier: 1.0,
                               constant: 0).isActive = true
            
            newView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        }
    }
}
