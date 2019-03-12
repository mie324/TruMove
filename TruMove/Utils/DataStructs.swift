//
//  DataStructs.swift
//  TruMove
//
//  Created by Damon on 2019-03-03.
//  Copyright © 2019 ece1778. All rights reserved.
//
import Foundation
import AVFoundation

struct AccData {
    let startTime: Double
    var endTime: Double
    var xArray: Array<Double>
    var yArray: Array<Double>
    var zArray: Array<Double>
    
    init(startTime: Double) {
        self.startTime = startTime
        self.endTime = 0.0
        self.xArray = []
        self.yArray = []
        self.zArray = []
    }
    
    init(startTime: Double, endTime: Double, xArray: Array<Double>, yArray: Array<Double>, zArray: Array<Double>) {
        self.startTime = startTime
        self.endTime = endTime
        self.xArray = xArray
        self.yArray = yArray
        self.zArray = zArray
    }
    
    // mode will be indicating which axis to use for idle detection, 1 = x, 2 = y, 3 = z
    func idleDetection(mode: Int) -> Bool {
        var array: Array<Double>
        if (mode == 1) {
            array = self.xArray
        } else if (mode == 2) {
            array = self.yArray
        } else {
            array = self.zArray
        }
        
        if (array.count > 6) {
            var diff = 0.0
            for i in stride(from: 3, to: 1, by: -1) {
                diff += array[array.count - i] - array[array.count - i - 1]
            }
            
            if (abs(diff) / 3.0 <= 0.007) {
                return true
            } else {
                return false
            }
            
        }
        return false
    }
    
    mutating func cleanUpNoise() {
        self.xArray.removeLast(4)
        self.yArray.removeLast(4)
        self.zArray.removeLast(4)
    }
    
    mutating func appendData(xVal: Double, yVal: Double, zVal: Double) {
        self.xArray.append(xVal)
        self.yArray.append(yVal)
        self.zArray.append(zVal)
    }
}

class PerformanceMatrix {
    func checkLimit(value: Double, lowerLimit: Double) {
        if (abs(value) >= lowerLimit) {
            let systemSoundID: SystemSoundID = 1005
            AudioServicesPlaySystemSound(systemSoundID)
        }
    }
}

class BicepCurlMatrix: PerformanceMatrix {
    public static var yAccLimit = Double(0.07)
}
