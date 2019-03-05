//
//  StatsViewController.swift
//  TruMove
//
//  Created by Damon on 2019-03-03.
//  Copyright © 2019 ece1778. All rights reserved.
//

import UIKit
import Charts
import Firebase

class StatsViewController: UIViewController {
    var histData: Array<Double> = []
    var chtChart: LineChartView! = {
        let chartView = LineChartView()
        chartView.backgroundColor = .white
        chartView.xAxis.labelPosition = .bottom
        return chartView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(chtChart)
        chtChart.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 20, paddingLeft: 10, paddingBottom: 60, paddingRight: 10, width: 300, height: 500)
        chtChart.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
        chtChart.xAxis.labelFont = UIFont(name: "Verdana", size: 16.0)!
        chtChart.leftAxis.labelFont = UIFont(name: "Verdana", size: 16.0)!
        chtChart.rightAxis.labelFont = UIFont(name: "Verdana", size: 16.0)!
        
        loadData()
    }
    
    func loadData() {
        Firestore.firestore().collection("9M5MFJlPy0ZVpdC97EiMBuOa8Bq2").addSnapshotListener { querySnapshot, error in
            if let err = error {
                print("Error getting data: \(err)")
            } else {
                querySnapshot!.documentChanges.forEach { diff in
                    let accData = AccData(startTime: diff.document.data()["starttime"] as! Double, endTime: diff.document.data()["endtime"] as! Double, xArray: diff.document.data()["x_value"] as! Array<Double>, yArray: diff.document.data()["y_value"] as! Array<Double>, zArray: diff.document.data()["z_value"] as! Array<Double>)
                    var total = 0.0
                    for num in accData.yArray {
                        total += num
                    }
                    total = total / Double(accData.yArray.count)
                    self.histData.append(total)
                }
                
                var lineDataEntry = [ChartDataEntry]()
                lineDataEntry.append(ChartDataEntry(x: 0, y: 0.0))
                for i in 0..<self.histData.count {
                    let value = ChartDataEntry(x: Double(i + 1), y: self.histData[i])
                    lineDataEntry.append(value)
                }
                
                let line = LineChartDataSet(values: lineDataEntry, label: "Historical Lateral Movement Data")
                line.colors = [NSUIColor.blue]
                line.lineWidth = 4
                line.drawCircleHoleEnabled = false
                let data = LineChartData()
                data.addDataSet(line)
                self.chtChart.data = data
                self.chtChart.reloadInputViews()
                
            }
        }
    }
}
