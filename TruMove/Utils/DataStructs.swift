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
    var lateralAccAvg: Double
    var lateralAccScore: Double
    var tampoAvg: Double
    
    init(startTime: Double) {
        self.startTime = startTime
        self.endTime = 0.0
        self.xArray = []
        self.yArray = []
        self.zArray = []
        self.lateralAccAvg = 0.0
        self.lateralAccScore = 0.0
        self.tampoAvg = 0.0
    }
    
    init(startTime: Double, endTime: Double, xArray: Array<Double>, yArray: Array<Double>, zArray: Array<Double>, lateralAccAvg: Double, lateralAccScore: Double, tampoAvg: Double) {
        self.startTime = startTime
        self.endTime = endTime
        self.xArray = xArray
        self.yArray = yArray
        self.zArray = zArray
        self.lateralAccAvg = lateralAccAvg
        self.lateralAccScore = lateralAccScore
        self.tampoAvg = tampoAvg
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
            
            if (abs(diff) / 3.0 <= 0.05) {
                return true
            } else {
                return false
            }
            
        }
        return false
    }
    
    func repDetection(mode: Int) -> Int {
        var array: Array<Double>
        if (mode == 1) {
            array = self.xArray
        } else if (mode == 2) {
            array = self.yArray
        } else {
            array = self.zArray
        }
        
        var result = 0;
        for i in 1...(array.count - 1) {
            if ((array[i] > 0 && array[i-1] < 0) || (array[i] < 0 && array[i-1] > 0)) {
                result += 1
            }
        }
        return array.count - 2
    }
    
    func calCulateAvg(mode: Int) -> Double {
        var array: Array<Double>
        if (mode == 1) {
            array = self.xArray
        } else if (mode == 2) {
            array = self.yArray
        } else {
            array = self.zArray
        }
        
        let cnt = array.count
        var total = 0.0
        for data in array {
            total = total + data
        }
        return (total / Double(cnt)).rounded(toPlaces: 3)
    }
    
    func calculateScore(mode: Int) -> Double {
        let x = abs(calCulateAvg(mode: mode))
        return (10 * ((0.5 - x) / 0.5)).rounded(toPlaces: 3)
    }
    
    func calculateAvgTampo(mode: Int) -> Double {
        var array1: Array<Double>
        var array2: Array<Double>
        if (mode == 1) {
            array1 = self.yArray
            array2 = self.zArray
        } else if (mode == 2) {
            array1 = self.xArray
            array2 = self.zArray
        } else {
            array1 = self.xArray
            array2 = self.yArray
        }
        
        let cnt = array1.count
        var total = 0.0
        for i in 0...(cnt - 1) {
            total = total + abs(array1[i]) + abs(array2[i])
        }
        
        return (total / Double(cnt)).rounded(toPlaces: 3)
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
    public static var yAccOnMoveLimit = Double(0.3)
    public static var yAccStaticLimit = Double(0.1)
    public static var tampoLimit = Double(1.5)
    
    public static var GOOD_TAMPO = "Tampo is good, keep it up!"
    public static var TAMPO_Fast = "You've been doing the workout using same tampo for the last couple of times, maybe speed it up a little?"
    public static var TAMPO_Slow = "You've been doing the workout using same tampo for the last couple of times, maybe slow it down a little?"
    public static var GOOD_LATERAL = "Lateral movement control is good, keep it up!"
    public static var LATERAL_LEFT = "Lateral movement control needs improvements. Your movement was a little bit to the left."
    public static var LATERAL_RIGHT = "Lateral movement control needs improvements. Your movement was a little bit to the right."
}
