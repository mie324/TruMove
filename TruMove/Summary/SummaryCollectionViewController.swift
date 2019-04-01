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
    
    typealias ItemInfo = (imageName: String, title: String, advice: String)
    fileprivate var cellsIsOpen = [Bool]()
    fileprivate let items: [ItemInfo] = [("item0", "Lateral Stability","Improve your lateral stability.\n You’re moving too far"), ("item1", "Tempo", "Switch up the tempo.\n  Go a little")]
    
    
    
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
    
//    fileprivate func getViewController() -> ExpandingTableViewController {
//        //let storyboard = UIStoryboard(storyboard: .Main)
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let toViewController: SummaryTableViewController = storyboard.instantiateViewController(withIdentifier: "SummaryTableViewController") as! SummaryTableViewController
//        return toViewController
//    }
    
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
            self.performSegue(withIdentifier: "NoName", sender: self)
            
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
        cell.backgroundImageView?.image = UIImage(named: info.imageName)
        cell.customTitle.text = info.title
        cell.conciseAdviceLabel.text = info.advice
        cell.cellIsOpen(cellsIsOpen[index], animated: false)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? SummaryCollectionViewCell
            , currentIndex == indexPath.row else { return }
        
        if cell.isOpened == false {
            cell.cellIsOpen(true)
        } else {
//            let vc: SummaryTableViewController = SummaryTableViewController(coder: 236)
//            pushToViewController(vc)
            
            self.performSegue(withIdentifier: "NoName", sender: self)
            
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

