//
//  SportIntroController.swift
// The first page of this sport, start button to the train page
//  groupproject
//
//  Created by Ellen Wang on 2019/3/1.
//  Copyright © 2019 ellen. All rights reserved.
//

import UIKit
import Firebase

class SportBreakDownController: UIViewController {
    
    //MARK: SET UP IMAGE
    var bannerImageView: UIImageView = {
        let biv = UIImageView()
        biv.contentMode = .scaleAspectFit
        biv.image = UIImage(named: "Weightlifting_Banner.png")
        return biv
    }()
    
    var move1ImageView: UIImageView = {
        let miv = UIImageView()
        miv.contentMode = .scaleAspectFit
        miv.image = UIImage(named: "Weightlifting_BicepCurl.png")
        
        return miv
    }()
    
    var move2ImageView: UIImageView = {
        let miv = UIImageView()
        miv.contentMode = .scaleAspectFit
        miv.image = UIImage(named: "Weightlifting_Snatch.png")
        
        return miv
    }()
    
    @objc func handleTap() {
        
        let singleMoveController = SingleMoveController()
        singleMoveController.perfMatrix = BicepCurlMatrix()
        singleMoveController.bannerImage = UIImage(named: "BicepsCurl_Banner.png")
        singleMoveController.introImage = UIImage(named: "BicepsCurl_Instructions.png")
        
        navigationController?.pushViewController(singleMoveController, animated: true)
        
    }
    //MARK: VIEW DID LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.isNavigationBarHidden = false
        move1ImageView.isUserInteractionEnabled = true
        move1ImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
        move2ImageView.isUserInteractionEnabled = true
        move2ImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
        
        setupPage()
        navigationItem.title = "TruMove"
        
        
    }
    
    // MARK: SET UP UI
    fileprivate func setupPage(){
        
        view.addSubview(bannerImageView)
        underNav(newView: bannerImageView)
        
        view.addSubview(move1ImageView)
        move1ImageView.anchor(top: bannerImageView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 5, paddingRight: 0, width: 0, height: 200)
        
        view.addSubview(move2ImageView)
        move2ImageView.anchor(top: move1ImageView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 5, paddingRight: 0, width: 0, height: 200)
        
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
