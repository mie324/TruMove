//
//  SummaryCollectionViewController.swift
//  TruMove
//
//  Created by Ellen Wang on 2019/4/1.
//  Copyright © 2019 ece1778. All rights reserved.
//

import UIKit
import expanding_collection

class SummaryCollectionViewController: ExpandingViewController {
    
    typealias ItemInfo = (imageName: String, title: String, scoreName: String, standardValue: String)
    fileprivate var cellsIsOpen = [Bool]()
    var items: [ItemInfo] = [("item0", "Lateral Stability","Your Score", "0.0"), ("item1", "Tempo", "Your set", "1.5")]
    
    // MARK: create texts to show in the tableview like "Your score is XXX, + concise advice, the score and concise advice can get from the segue.
    typealias PassDataInfo = (scoreValue: String, adviceText: String)
    var passData : [PassDataInfo] = [("0.0", " "), ("0.0", " ")]
    
    var results: [String] = [
        "Improve your lateral stability by avoiding side-to-side movements. This will help you:\n\n   Maximize the efficiency of your workout\n   Prevent injuries\n   Prevent muscle imbalances",
        "Varying the tempo will help you:\n\n   Prevent performance plateaus\n   Improve control during lifts\n   Develop your muscles and connective tissues"]
    

    
    
    @IBOutlet var pageLabel: UILabel!
}

// MARK: - Lifecycle 🌎

extension SummaryCollectionViewController {
    
    override func viewDidLoad() {
        itemSize = CGSize(width: 256, height: 460)
        super.viewDidLoad()
        
        registerCell()
        fillCellIsOpenArray()
        addGesture(to: collectionView!)
        configureNavBar()
    }
}

// MARK: Helpers

extension SummaryCollectionViewController {
    
    fileprivate func registerCell() {
        
        let nib = UINib(nibName: String(describing: SummaryCollectionViewCell.self), bundle: nil)
        collectionView?.register(nib, forCellWithReuseIdentifier: String(describing: SummaryCollectionViewCell.self))
    }
    
    fileprivate func fillCellIsOpenArray() {
        cellsIsOpen = Array(repeating: false, count: items.count)
    }
    
    fileprivate func getViewController(adviceText: String, detailedText: String) -> ExpandingTableViewController {

        let viewController:SummaryTableViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SummaryTableViewController") as! SummaryTableViewController
        viewController.adviceText = adviceText
        viewController.detailedText = detailedText
    
        return viewController
    }
    
    fileprivate func configureNavBar() {
        navigationItem.rightBarButtonItem?.image = navigationItem.rightBarButtonItem?.image!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
    }
}

/// MARK: Gesture
extension SummaryCollectionViewController {
    
    fileprivate func addGesture(to view: UIView) {
        let upGesture = Init(UISwipeGestureRecognizer(target: self, action: #selector(SummaryCollectionViewController.swipeHandler(_:)))) {
            $0.direction = .up
        }
        
        let downGesture = Init(UISwipeGestureRecognizer(target: self, action: #selector(SummaryCollectionViewController.swipeHandler(_:)))) {
            $0.direction = .down
        }
        view.addGestureRecognizer(upGesture)
        view.addGestureRecognizer(downGesture)
    }
    
    @objc func swipeHandler(_ sender: UISwipeGestureRecognizer) {
        let indexPath = IndexPath(row: currentIndex, section: 0)
        guard let cell = collectionView?.cellForItem(at: indexPath) as? SummaryCollectionViewCell else { return }
        // double swipe Up transition
        if cell.isOpened == true && sender.direction == .up {
            let index = indexPath.row % items.count
            let passdata = passData[index]

            pushToViewController(getViewController(adviceText: passdata.adviceText, detailedText: results[index]))
            if let rightButton = navigationItem.rightBarButtonItem as? AnimatingBarButton {
                rightButton.animationSelected(true)
            }
        }
        
        let open = sender.direction == .up ? true : false
        cell.cellIsOpen(open)
        cellsIsOpen[indexPath.row] = cell.isOpened
    }
}

// MARK: UIScrollViewDelegate

extension SummaryCollectionViewController {
    
    func scrollViewDidScroll(_: UIScrollView) {
        pageLabel.text = "\(currentIndex + 1)/\(items.count)"
    }
}

// MARK: UICollectionViewDataSource

extension SummaryCollectionViewController {
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        super.collectionView(collectionView, willDisplay: cell, forItemAt: indexPath)
        guard let cell = cell as? SummaryCollectionViewCell else { return }
        
        let index = indexPath.row % items.count
        let info = items[index]
        let passdata = passData[index]
        cell.backgroundImageView?.image = UIImage(named: info.imageName)
        cell.customTitle.text = info.title
        cell.standardValueLabel.text = info.standardValue
        cell.scoreNameLabel.text = info.scoreName
        cell.userScoreLabel.text = passdata.scoreValue
        cell.cellIsOpen(cellsIsOpen[index], animated: false)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? SummaryCollectionViewCell
            , currentIndex == indexPath.row else { return }
        
        if cell.isOpened == false {
            cell.cellIsOpen(true)
        } else {
            let index = indexPath.row % items.count
            let passdata = passData[index]
            
            pushToViewController(getViewController(adviceText: passdata.adviceText, detailedText: results[index]))
            
            if let rightButton = navigationItem.rightBarButtonItem as? AnimatingBarButton {
                rightButton.animationSelected(true)
            }
        }
    }
}

// MARK: UICollectionViewDataSource

extension SummaryCollectionViewController {
    
    override func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return items.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: SummaryCollectionViewCell.self), for: indexPath)
    }
}

