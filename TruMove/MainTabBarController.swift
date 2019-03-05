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
        let sportSearchVC = SportSearchController(collectionViewLayout: UICollectionViewFlowLayout())
        let searchNavVC = UINavigationController(rootViewController: sportSearchVC)
        let statsVC = StatsViewController()

        searchNavVC.tabBarItem.image = UIImage(named:"train")
        statsVC.tabBarItem.image = UIImage(named:"stats")

        view.backgroundColor = .white
        tabBar.tintColor = .black

        viewControllers = [searchNavVC, statsVC]

        //modify tab bar item insets
        guard let items = tabBar.items else { return }
        items[0].imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        items[1].imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -2, right: 0)
    }
}
