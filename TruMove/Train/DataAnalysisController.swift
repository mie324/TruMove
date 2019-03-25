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
    
    var circleImageView: UIImageView = {
        let civ = UIImageView()
        civ.contentMode = .scaleAspectFit
        return civ
    }()
    
    var literalAccLabel: UILabel = {
        let lb = UILabel()
        lb.backgroundColor = .white
        lb.font = UIFont.boldSystemFont(ofSize: 20)
        lb.textColor = UIColor.gray
        lb.textAlignment = .center
        lb.text = "Average Lateral Acceleration"
        return lb
    }()
    
    var averValueLabel: UILabel = {
        let vlb = UILabel()
        vlb.backgroundColor = .white
        vlb.text = "0.0"
        vlb.font = UIFont(name: "HelveticaNeue-medium", size: CGFloat(26))
        vlb.textAlignment = .center
        return vlb
    }()
    
    var scoreLabel: UILabel = {
        let lb = UILabel()
        lb.backgroundColor = .white
        lb.font = UIFont.boldSystemFont(ofSize: 20)
        lb.textColor = UIColor.gray
        lb.textAlignment = .center
        lb.text = "Lateral Stability Score"
        return lb
    }()
    
    var scoreValueLabel: UILabel = {
        let vlb = UILabel()
        vlb.backgroundColor = .white
        vlb.text = "0"
        vlb.font = UIFont(name: "HelveticaNeue-medium", size: CGFloat(26))
        vlb.textAlignment = .center
        return vlb
    }()
    
    var feedBackLabel: UILabel = {
        let lb = UILabel()
        lb.backgroundColor = .white
        lb.font = UIFont.boldSystemFont(ofSize: 20)
        lb.textColor = UIColor.gray
        lb.textAlignment = .center
        lb.text = "Workout Feedbacks:"
        return lb
    }()
    
    var lateralMoveFeedback: UILabel = {
        let lb = UILabel()
        lb.backgroundColor = .white
        lb.font = UIFont.boldSystemFont(ofSize: 20)
        lb.textColor = UIColor.gray
        lb.textAlignment = .center
        lb.text = "lateral feedback"
        return lb
    }()
    
    var tampoFeedback: UILabel = {
        let lb = UILabel()
        lb.backgroundColor = .white
        lb.font = UIFont.boldSystemFont(ofSize: 20)
        lb.textColor = UIColor.gray
        lb.textAlignment = .center
        lb.text = "tampo feedback"
        return lb
    }()
    
    var accData: AccData!
    var lateralAccAvg: Double!
    var lateralStabilityScore: Double!
    var mode: Int!
    
    //MARK: SET UP ASSESSMENT ALERT VIEW
    override func viewDidAppear(_ animated: Bool){
        
        super.viewDidAppear(animated)
         setUpAlert()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = false
        navigationItem.title = "TruMove"
        
        view.backgroundColor = .white
        
        setupPage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        renderLateralItems()
        renderTampoItems()
    }
    
    fileprivate func setUpAlert(){
        
        let alertController = UIAlertController(title: "Assess Standard\n\n",message: " Average lateral acceleration: 0\n The value of Lateral stability score: 0.\n", preferredStyle: .alert)
        
        let backView = alertController.view.subviews.last?.subviews.last
        backView?.layer.cornerRadius = 10.0
        backView?.backgroundColor = UIColor.white
        
        let myString  = "Assess Standard\n\n"
        var myMutableString = NSMutableAttributedString()
        myMutableString = NSMutableAttributedString(string: myString as String, attributes: [NSAttributedString.Key.font:UIFont(name: "Georgia", size: 25.0)!])
        myMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.gray, range: NSRange(location:0,length:myString.count))
        alertController.setValue(myMutableString, forKey: "attributedTitle")
        
        let message  = "Average lateral acceleration: 0\n\n The value of Lateral stability score: 10\n\n"
        var messageMutableString = NSMutableAttributedString()
        messageMutableString = NSMutableAttributedString(string: message as String, attributes: [NSAttributedString.Key.font:UIFont(name: "Georgia", size: 20.0)!])
        messageMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: NSRange(location:0,length:message.count))
        alertController.setValue(messageMutableString, forKey: "attributedMessage")
        
        
        let clickAction = UIAlertAction(title: "OK, I Aware", style: .cancel, handler: nil)
        clickAction.setValue(UIColor.blue, forKey: "titleTextColor")
        alertController.addAction(clickAction)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    
    fileprivate func setupPage(){
        
        view.addSubview(bannerImageView)
        underNav(newView: bannerImageView)

        view.addSubview(circleImageView)
        circleImageView.anchor(top: bannerImageView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: circleImageView.frame.width, height: circleImageView.frame.height)
        
        
        circleImageView.addSubview(averValueLabel)
        averValueLabel.anchor(top: bannerImageView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 90, paddingLeft: 130, paddingBottom: 50, paddingRight: 130, width: circleImageView.frame.width, height: circleImageView.frame.height)
        
        
        view.addSubview(literalAccLabel)
        literalAccLabel.anchor(top: circleImageView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 50)
        
        view.addSubview(scoreLabel)
        scoreLabel.anchor(top: circleImageView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 100, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 50)
        
        view.addSubview(scoreValueLabel)
        scoreValueLabel.anchor(top: scoreLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 50)
        
        view.addSubview(feedBackLabel)
        feedBackLabel.anchor(top: scoreValueLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 50)
        
        view.addSubview(lateralMoveFeedback)
        lateralMoveFeedback.anchor(top: feedBackLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 50)
        
        view.addSubview(tampoFeedback)
        tampoFeedback.anchor(top: lateralMoveFeedback.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 50)
    }
    
    func renderLateralItems() {
        self.averValueLabel.text = String(self.lateralAccAvg)
        self.scoreValueLabel.text = String(self.lateralStabilityScore)
        if (abs(self.lateralAccAvg) > BicepCurlMatrix.yAccStaticLimit){
            self.circleImageView.image = UIImage(named: "Feedback_CircleRed")
            if (self.lateralAccAvg < 0) {
                self.lateralMoveFeedback.text = BicepCurlMatrix.LATERAL_RIGHT
            } else {
                self.lateralMoveFeedback.text = BicepCurlMatrix.LATERAL_LEFT
            }
        } else {
            self.circleImageView.image = UIImage(named: "Feedback_CircleGreen")
            self.lateralMoveFeedback.text = BicepCurlMatrix.GOOD_LATERAL
        }
    }
    
    func renderTampoItems() {
        Firestore.firestore().collection("bicepCurl").order(by: "starttime", descending: true).limit(to: 3).getDocuments() { (querySnapshot, err) in
            var histData: Array<AccData> = []
            querySnapshot!.documents.forEach { document in
                let accData = AccData(startTime: document.data()["starttime"] as! Double, endTime: document.data()["endtime"] as! Double, xArray: document.data()["x_value"] as! Array<Double>, yArray: document.data()["y_value"] as! Array<Double>, zArray: document.data()["z_value"] as! Array<Double>, lateralAccAvg: document.data()["literalAccAvg"] as! Double, lateralAccScore: document.data()["literalStabilityScore"] as! Double, tampoAvg: document.data()["tampoAvg"] as! Double)
                histData.append(accData)
            }
            
            var total = 0.0
            for data in histData {
                total += data.tampoAvg
            }
            
            let tampoAvg = total / Double(histData.count)
            
            if (tampoAvg < BicepCurlMatrix.tampoLimit) {
                self.tampoFeedback.text = BicepCurlMatrix.TAMPO_Fast
            } else {
                 self.tampoFeedback.text = BicepCurlMatrix.TAMPO_Slow
            }
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
