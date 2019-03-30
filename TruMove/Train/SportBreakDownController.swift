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
import FoldingCell

class SportBreakDownController: UITableViewController {
    
    var guidelineAlert: UIAlertController!
    
    @IBAction func guidelineButtonTabbed(_ sender: Any) {
        /**
        guidelineAlert = UIAlertController(title: "Guidelines", message: "foo bar", preferredStyle: .alert)
        
        let title = "Guidelines\n\n"
        let titleMutableString = NSMutableAttributedString(string: title as String, attributes: [NSAttributedString.Key.font:UIFont(name: "Georgia-Bold", size: 25.0)!])
        titleMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.gray, range: NSRange(location: 0, length: title.count))
        guidelineAlert.setValue(titleMutableString, forKey: "attributedTitle")
        
        let instructions = NSMutableAttributedString(string: "Lateral Stability\n", attributes: [NSAttributedString.Key.font:UIFont(name: "Georgia-Bold", size: 22.0)!])
        let instructions1 = NSMutableAttributedString(string: "Reducing side-to-side movement will help you get the most out of your workout. Avoid lateral asymmetries to prevent injuries.\n\n", attributes: [NSAttributedString.Key.font:UIFont(name: "Georgia", size: 22.0)!])
        let instructions2 = NSMutableAttributedString(string: "Tempo\n", attributes: [NSAttributedString.Key.font:UIFont(name: "Georgia-Bold", size: 22.0)!])
        let instructions3 = NSMutableAttributedString(string: "Varying your rep speed will shock your muscles and prevent plateaus.\n\n", attributes: [NSAttributedString.Key.font:UIFont(name: "Georgia", size: 22.0)!])
        instructions.append(instructions1)
        instructions.append(instructions2)
        instructions.append(instructions3)
        guidelineAlert.setValue(instructions, forKey: "attributedMessage")
        
        let ackAction = UIAlertAction(title: "Ok, Got it", style: .cancel) { (action:UIAlertAction) in
            self.guidelineAlert.dismiss(animated: true, completion: nil)
        }
        
        guidelineAlert.addAction(ackAction)
        guidelineAlert.view.frame = CGRect(x: 20, y: 100, width: 300, height: 400);
        self.present(guidelineAlert, animated: true, completion: nil)
         **/
        
        let guidelineAlert = self.storyboard?.instantiateViewController(withIdentifier: "GuidelineAlertID") as! GuidelineViewController
        guidelineAlert.providesPresentationContextTransitionStyle = true
        guidelineAlert.definesPresentationContext = true
        guidelineAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        guidelineAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.present(guidelineAlert, animated: true, completion: nil)
    }
    
    //MARK: DATA
    //tbd: need a class to generalize this
    
    var moves = ["Weightlifting_BicepCurl","Weightlifting_Snatch"]
    var instructions = ["BicepsCurl","Snatch"]
    var firstInstruct = ["1. Start with your arms straight, and grip the bar at shoulder-width", "1. Start with your back flat, arms straight down, knees bent, and toes and grip at shoulder-width\n 2. Quickly extend your knees and shrug your shoulders as you raise the bar over your head"]
    var secondInstruct = ["2. Raise the bar by bending at the elbows", "3. Lock your elbows as you move into a squat position"]
    var thirdInstruct = ["3. Avoid moving side-to-side during your workout", "4. Stand and drop the bar forward\n5. Avoid moving side-to-side during your workout"]
    
    //MARK: Folding cell
    enum Const {
        static let closeCellHeight: CGFloat = 200
        static let openCellHeight: CGFloat = 800
        static let rowsCount = 2
    }
    
    var cellHeights: [CGFloat] = []
    
    //MARK: VIEW DID LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
    
    private func setUp() {
        cellHeights = Array(repeating: Const.closeCellHeight, count: Const.rowsCount)
        tableView.estimatedRowHeight = Const.closeCellHeight
        tableView.rowHeight = UITableView.automaticDimension
    }
}

// MARK: - TableView

extension SportBreakDownController {
    
    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return 2
    }
    
    override func tableView(_: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard case let cell as SportBreakDownCell = cell else {
            return
        }
        
        cell.backgroundColor = .clear
        
        if cellHeights[indexPath.row] == Const.closeCellHeight {
            cell.unfold(false, animated: false, completion: nil)
        } else {
            cell.unfold(true, animated: false, completion: nil)
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FoldingCell", for: indexPath) as! SportBreakDownCell
        let durations: [TimeInterval] = [0.26, 0.2, 0.2]
        cell.durationsForExpandedState = durations
        cell.durationsForCollapsedState = durations
        
        let move = moves[indexPath.row] + ".png"
        let instruction = instructions[indexPath.row]
        let fInstruct = firstInstruct[indexPath.row]
        let sInstruct = secondInstruct[indexPath.row]
        let tInstruct = thirdInstruct[indexPath.row]
        
        cell.setUp(moveName: instruction, bannerImage: UIImage(named: move)!, insImage: UIImage(named: (instruction+".png"))!,fInstruct: fInstruct, sInstruct: sInstruct, tInstruct: tInstruct)
        
        return cell
    }
    
    override func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeights[indexPath.row]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! SportBreakDownCell
        
        if cell.isAnimating() {
            return
        }
        
        var duration = 0.0
        let cellIsCollapsed = cellHeights[indexPath.row] == Const.closeCellHeight
        if cellIsCollapsed {
            cellHeights[indexPath.row] = Const.openCellHeight
            cell.unfold(true, animated: true, completion: nil)
            duration = 0.5
        } else {
            cellHeights[indexPath.row] = Const.closeCellHeight
            cell.unfold(false, animated: true, completion: nil)
            duration = 0.8
        }
        
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: { () -> Void in
            tableView.beginUpdates()
            tableView.endUpdates()
        }, completion: nil)
    }
}
