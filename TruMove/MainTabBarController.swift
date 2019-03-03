//
//  MainTabBarController.swift
//  groupproject
//
//  Created by Ellen Wang on 2019/3/1.
//  Copyright © 2019 ellen. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        
                if Auth.auth().currentUser == nil {
                    //show if not logged in
                    DispatchQueue.main.async {
                        let loginController = LoginController()
                        let navController = UINavigationController(rootViewController: loginController)
                        self.present(navController, animated: true, completion: nil)
                    }
        
                    return
                }

        setupViewControllers()
    }
    
    
    //MARK: SET UP TAB BAR
    func setupViewControllers() {

        //search for sports page
        let searchNavController = templateNavController(unselectedImage:#imageLiteral(resourceName: "search"), selectedImage: #imageLiteral(resourceName: "search"), rootViewController:SportSearchController(collectionViewLayout: UICollectionViewFlowLayout()))
        
        //other two pages
        // A PROBLEM HERE! these two images don't display
        let statsController = templateNavController(unselectedImage: #imageLiteral(resourceName: "stats"), selectedImage:#imageLiteral(resourceName: "stats"))
        
        let profileController = templateNavController(unselectedImage: #imageLiteral(resourceName: "user"), selectedImage: #imageLiteral(resourceName: "user"))

        view.backgroundColor = .white
        
        tabBar.tintColor = .black
        
        viewControllers = [statsController,
                           searchNavController,
                           profileController
                           ]
        
        //modify tab bar item insets
        guard let items = tabBar.items else { return }
        
        for item in items {
            item.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        }
    }
    
    fileprivate func templateNavController(unselectedImage: UIImage, selectedImage: UIImage, rootViewController: UIViewController = UIViewController()) -> UINavigationController {
        let viewController = rootViewController
        let navController = UINavigationController(rootViewController: viewController)
        navController.tabBarItem.image = unselectedImage
        navController.tabBarItem.selectedImage = selectedImage
        return navController
    }

}
