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
    var histData: Array<AccData> = []
    var scores: Array<Double> = []
    var chtChart: LineChartView! = {
        let chartView = LineChartView()
        chartView.backgroundColor = .white
        chartView.xAxis.labelPosition = .bottom
        return chartView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(chtChart)
        chtChart.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 20, paddingLeft: 10, paddingBottom: 60, paddingRight: 10, width: 300, height: 400)
        chtChart.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
        chtChart.xAxis.labelFont = UIFont(name: "Verdana", size: 16.0)!
        chtChart.leftAxis.labelFont = UIFont(name: "Verdana", size: 16.0)!
        chtChart.rightAxis.labelFont = UIFont(name: "Verdana", size: 16.0)!

        loadData()
    }

    func loadData() {
        Firestore.firestore().collection("bicepCurl").addSnapshotListener { querySnapshot, error in
            if let err = error {
                print("Error getting data: \(err)")
            } else {
                self.histData = []
                querySnapshot!.documents.forEach { document in
                    let accData = AccData(startTime: document.data()["starttime"] as! Double, endTime: document.data()["endtime"] as! Double, xArray: document.data()["x_value"] as! Array<Double>, yArray: document.data()["y_value"] as! Array<Double>, zArray: document.data()["z_value"] as! Array<Double>, lateralAccAvg: document.data()["literalAccAvg"] as! Double, lateralAccScore: document.data()["literalStabilityScore"] as! Double, tampoAvg: document.data()["tampoAvg"] as! Double)
                    self.histData.append(accData)
                }
                
                self.histData.sort { (data1: AccData, data2: AccData) in
                    return data1.startTime < data2.startTime
                }
                
                self.scores = []
                for data in self.histData {
                    self.scores.append(data.lateralAccAvg)
                }
                
                var lineDataEntry = [ChartDataEntry]()
                lineDataEntry.append(ChartDataEntry(x: 0, y: 0.0))
                for i in 0..<self.scores.count {
                    let value = ChartDataEntry(x: Double(i + 1), y: self.scores[i])
                    lineDataEntry.append(value)
                }

                let line = LineChartDataSet(values: lineDataEntry, label: "Historical Lateral Acceleration Data")
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
