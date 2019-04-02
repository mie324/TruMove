//
//  SummaryTableViewController.swift
//  TruMove
//
//  Created by Ellen Wang on 2019/4/1.
//  Copyright © 2019 ece1778. All rights reserved.
//

import UIKit
import expanding_collection

class SummaryTableViewController : ExpandingTableViewController {
    
    var adviceText : String = "advice"
    var detailedText : String = "detailed advice"
    
    fileprivate var scrollOffsetY: CGFloat = 0
    
    @IBOutlet var detailAdviceText: UILabel!
 
    @IBOutlet var tableview: UITableView!
    @IBOutlet var conciseAdviceLabel: UILabel!
    
    @IBAction func backHandler(_: AnyObject) {
        // buttonAnimation
        let viewControllers: [SummaryCollectionViewController?] = navigationController?.viewControllers.map { $0 as? SummaryCollectionViewController } ?? []

        for viewController in viewControllers {
            if let rightButton = viewController?.navigationItem.rightBarButtonItem as? AnimatingBarButton {
                rightButton.animationSelected(false)
            }
        }
        popTransitionAnimation()
        
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        headerHeight = 236
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavBar()
        self.conciseAdviceLabel.text =  adviceText
        self.detailAdviceText.text = detailedText
//        let image1 = Asset.backgroundImage.image
//        tableView.backgroundView = UIImageView(image: image1)
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
    }
    
    
    
}

// MARK: Helpers

extension SummaryTableViewController {
    
    fileprivate func configureNavBar() {
        navigationItem.leftBarButtonItem?.image = navigationItem.leftBarButtonItem?.image!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        navigationItem.rightBarButtonItem?.image = navigationItem.rightBarButtonItem?.image!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
    }
}



// MARK: UIScrollViewDelegate

extension SummaryTableViewController {
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < -25 , let navigationController = navigationController {
            // buttonAnimation
            for case let viewController as SummaryCollectionViewController in navigationController.viewControllers {
                if case let rightButton as AnimatingBarButton = viewController.navigationItem.rightBarButtonItem {
                    rightButton.animationSelected(false)
                }
            }
            popTransitionAnimation()
        }
        scrollOffsetY = scrollView.contentOffset.y
    }
}

