//
//  DataStructs.swift
//  TruMove
//
//  Created by Damon on 2019-03-03.
//  Copyright © 2019 ece1778. All rights reserved.
//
import Foundation

struct AccData {
    let startTime: Double
    let endTime: Double
    let xArray: Array<Double>
    let yArray: Array<Double>
    let zArray: Array<Double>
    
    init(startTime: Double, endTime: Double, xArray: Array<Double>, yArray: Array<Double>, zArray: Array<Double>) {
        self.startTime = startTime
        self.endTime = endTime
        self.xArray = xArray
        self.yArray = yArray
        self.zArray = zArray
    }
}
