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
    
    var xArray = Array<Double>()
    var yArray = Array<Double>()
    var zArray = Array<Double>()
    
    //MARK: SET UP LABELS
    var useridLabel: UILabel = {
        let label = UILabel()
        label.text = "username"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    
    var timeLabel: UILabel = {
        let label = UILabel()
        label.text = "starttime"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    
    var dataLabel: UILabel = {
        let label = UILabel()
        label.text = "xvalue"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    
    var starttime = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        view.backgroundColor = .white
        
        view.addSubview(useridLabel)
        useridLabel.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 150)
        view.addSubview(timeLabel)
        timeLabel.anchor(top: useridLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 100)
        view.addSubview(dataLabel)
        dataLabel.anchor(top: timeLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 100)
        
        fetchData()
        
    }
    
    //MARK: READ DATA 
    fileprivate func fetchData() {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        useridLabel.text = uid
        timeLabel.text = String(self.starttime)
        let ref = Firestore.firestore().collection(uid)
        let query = ref.whereField("starttime", isEqualTo: starttime)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        var text = " "
                        let xArray = document.get("x_value") as? [Double]
                        for data in xArray!{
                            text = text + String(data) + " ,"
                        }
                        self.dataLabel.text = text
                    }
                }
        }
        
    }
}
