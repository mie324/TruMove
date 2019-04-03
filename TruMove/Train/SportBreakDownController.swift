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
    var mainInstructions:[[String]] = [
        ["1. Start with your arms straight, and grip the bar at shoulder-width", "2. Raise the bar by bending at the elbows", "3. Avoid moving side-to-side during your workout"],
        ["1. Start with your back flat, arms straight down, knees bent, and toes and grip at shoulder-width", "2. Quickly extend your knees and shrug your shoulders as you raise the bar over your head", "3. Lock your elbows as you move into a squat position", "4. Stand and drop the bar forward", "5. Avoid moving side-to-side during your workout"]
    ]

  
    
    //MARK: Folding cell
    enum Const {
        static let closeCellHeight: CGFloat = 200
        static let openCellHeight: CGFloat = 850
        static let rowsCount = 2
    }
    
    var cellHeights: [CGFloat] = []
    
    //MARK: VIEW DID LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
        checkNewUser()
    }
    
    private func setUp() {
        cellHeights = Array(repeating: Const.closeCellHeight, count: Const.rowsCount)
        tableView.estimatedRowHeight = Const.closeCellHeight
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    func checkNewUser() {
        Firestore.firestore().collection("register").document((Auth.auth().currentUser?.uid)!).getDocument {
            (document, error) in
            if let document = document, document.exists {
                let newUser = document.data()!["new"] as! Bool
                if (newUser) {
                    self.guidelineButtonTabbed(self)
                    Firestore.firestore().collection("register").document((Auth.auth().currentUser?.uid)!).setData([
                        "new": false
                    ]) { err in
                        if let err = err {
                            print("Error adding document: \(err)")
                        }
                    }
                }
            }
        }
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
        var mainInstruct = mainInstructions[indexPath.row]

        
        cell.setUp(moveName: instruction.uppercased(), bannerImage: UIImage(named: move)!, insImage: UIImage(named: (instruction+".png"))!,mainInstruct: mainInstruct)
        
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
