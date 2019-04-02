
//
//  SportIntroController.swift
// The first page of this sport, start button to the train page
//
//  Created by Ellen Wang on 2019/3/1.
//  Copyright © 2019 ellen. All rights reserved.
//

import UIKit
import Firebase
import CoreBluetooth
import SwiftEntryKit
import AVFoundation

class SingleMoveController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    var centralManager : CBCentralManager!
    var sensorTagPeripheral : CBPeripheral!
    
    let MovementServiceUUID = CBUUID(string: "F000AA80-0451-4000-B000-000000000000")
    let MovementDataUUID = CBUUID(string: "F000AA81-0451-4000-B000-000000000000")
    let MovementConfigUUID = CBUUID(string: "F000AA82-0451-4000-B000-000000000000")
    var accData: AccData!
    var lateralAccAvg: Double!
    var lateralStabilityScore: Double!
    var tampoAvg: Double!
    
    var timer:Timer?
    var timeLeft = 3
    var countDownAlert: UIAlertController!
    
    var startedRecord = false
    
    var bannerImage: UIImage!
    var introImage: UIImage!
    let perfMatrix = PerformanceMatrix()
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var startsportButton: UIButton!
    @IBOutlet weak var endsportButton: UIButton!
    
    @IBOutlet weak var currentLateral: UILabel!
    @IBOutlet weak var lateralStatusImage: UIImageView!
    @IBOutlet weak var dumbbellImage: UIImageView!
    
    let dumbbellUpperY = 330
    let dumbbellLowerY = 575
    let dumbbellX = 207
    let dumbbellSpeed = 1.0
    
    //MARK: START BUTTON
    @IBAction func startButtonTapped(_ sender: Any) {
        if statusLabel.text != "Ready" {
            startsportButton.isEnabled = false
            return;
        }
        self.performSegue(withIdentifier: "countdown", sender: self)
    }
    
    
    
   
    
    func recordData() {
        endsportButton.isEnabled = true
        accData = AccData(startTime: Date().timeIntervalSince1970)
        statusLabel.text = "Recording Data"
    }
    
    func doReps() {
        let upperDes = CGPoint(x: dumbbellX, y: dumbbellUpperY)
        let lowerDes = CGPoint(x: dumbbellX, y: dumbbellLowerY)
        let upDuration = self.dumbbellSpeed
        let lowDuration = self.dumbbellSpeed
        
        UIView.animate(withDuration: upDuration, delay: 0, options: UIView.AnimationOptions.curveLinear, animations: {
            self.dumbbellImage.center = upperDes
        }, completion: {(success) in
            UIView.animate(withDuration: lowDuration, delay: 0, options: UIView.AnimationOptions.curveLinear, animations: {
                self.dumbbellImage.center = lowerDes
            }, completion: {(success) in
                UIView.animate(withDuration: upDuration, delay: 0, options: UIView.AnimationOptions.curveLinear, animations: {
                    self.dumbbellImage.center = upperDes
                }, completion: {(success) in
                    UIView.animate(withDuration: lowDuration, delay: 0, options: UIView.AnimationOptions.curveLinear, animations: {
                        self.dumbbellImage.center = lowerDes
                    }, completion: {(success) in
                        UIView.animate(withDuration: upDuration, delay: 0, options: UIView.AnimationOptions.curveLinear, animations: {
                            self.dumbbellImage.center = upperDes
                        }, completion: {(success) in
                            UIView.animate(withDuration: lowDuration, delay: 0, options: UIView.AnimationOptions.curveLinear, animations: {
                                self.dumbbellImage.center = lowerDes
                            }, completion: {(success) in
                                UIView.animate(withDuration: upDuration, delay: 0, options: UIView.AnimationOptions.curveLinear, animations: {
                                    self.dumbbellImage.center = upperDes
                                }, completion: {(success) in
                                    UIView.animate(withDuration: lowDuration, delay: 0, options: UIView.AnimationOptions.curveLinear, animations: {
                                        self.dumbbellImage.center = lowerDes
                                    }, completion: {(success) in
                                        // list of sounds: https://github.com/TUNER88/iOSSystemSoundsLibrary
                                        let systemSoundID: SystemSoundID = 1057
                                        AudioServicesPlaySystemSound(systemSoundID)
                                        self.statusLabel.text = "Data recording ended"
                                        self.startedRecord = false
                                    })
                                })
                            })
                        })
                    })
                })
            })
        })
    }
    
    //MARK: END BUTTON
    @IBAction func endButtonTapped(_ sender: Any) {
        //save data
        disconnectSensorTag()
        self.statusLabel.text = "Stopped Recording"
        self.startedRecord = false
        self.accData.endTime = Date().timeIntervalSince1970
        
        self.lateralAccAvg = self.accData.calCulateAvg(mode: 2)
        self.lateralStabilityScore = self.accData.calculateScore(mode: 2)
        self.tampoAvg = self.accData.calculateAvgTampo(mode: 2)
        
        saveData()
        //open the data analysis page
        let alert = UIAlertController(title: "Data Saved!", message:"Would you like to review the workout summary?", preferredStyle: .alert)
        
        let action1 = UIAlertAction(title: "Sure", style: .default) { (action:UIAlertAction) in
            self.performSegue(withIdentifier: "goToSummary", sender: self)
        }
        
        let action2 = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction) in
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(action1)
        alert.addAction(action2)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToSummary" {
            let dvc = segue.destination as! SummaryCollectionViewController
//            dvc.accData = self.accData
//            dvc.mode = 2
//            dvc.lateralAccAvg = self.lateralAccAvg
//            dvc.lateralStabilityScore = self.lateralStabilityScore
            var lateralConciseAdvice = "Lateral movement control is good, keep it up!"
            var tampoConciseAdvice = "Tampo is good, keep it up!"
            if self.lateralStabilityScore > 0.0 {
                lateralConciseAdvice = "Lateral movement control needs improvements. Your movement was a little bit to the right."
            }
            else if self.lateralStabilityScore < 0.0{
                lateralConciseAdvice = "Lateral movement control needs improvements. Your movement was a little bit to the left."
            }
            if self.tampoAvg > 1.5 {
                tampoConciseAdvice = "You've been doing the workout using same tampo for the last couple of times, maybe speed it up a little?"
            }
            else if self.tampoAvg < 1.5{
                tampoConciseAdvice = "You've been doing the workout using same tampo for the last couple of times, maybe slow it down a little?"
            }
            var passData = dvc.passData
            passData[0] = ("\(String(describing: self.lateralStabilityScore))",lateralConciseAdvice)
            passData[1] = ("\(String(describing: self.tampoAvg))",tampoConciseAdvice)

        }
    }
    
    fileprivate func saveData(){
        Firestore.firestore().collection("bicepCurl").addDocument(data:[
            "x_value": self.accData.xArray,
            "y_value": self.accData.yArray,
            "z_value": self.accData.zArray,
            "literalAccAvg": self.lateralAccAvg,
            "literalStabilityScore": self.lateralStabilityScore,
            "tampoAvg" : self.tampoAvg,
            "starttime": self.accData.startTime,
            "endtime": self.accData.endTime]){ err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("user saved!")
                }
        }
    }
    
    //MARK: NAV ITEM
    
    @IBAction func backButtonTapped(_ sender: Any) {
        disconnectSensorTag()
        self.performSegue(withIdentifier: "backToSelection", sender: self)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    
    
    //MARK: IMPLEMENT SENSOR
    func disconnectSensorTag() {
        if (self.sensorTagPeripheral != nil) {
            self.centralManager.cancelPeripheralConnection(self.sensorTagPeripheral)
        }
    }
    
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == CBManagerState.poweredOn {
            // Scan for peripherals if BLE is turned on
            central.scanForPeripherals(withServices: nil, options: nil)
            self.statusLabel.text = "Searching for BLE Devices"
        }
        else {
            // Can have different conditions for all states if needed - print generic message for now
            print("Bluetooth switched off or not initialized")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        let deviceName = "CC2650 SensorTag"
        let nameOfDeviceFound = (advertisementData as NSDictionary).object(forKey: CBAdvertisementDataLocalNameKey) as? String
        
        if (nameOfDeviceFound == deviceName) {
            // Update Status Label
            self.statusLabel.text = "Sensor Tag Found"
            
            // Stop scanning
            self.centralManager.stopScan()
            // Set as the peripheral to use and establish connection
            self.sensorTagPeripheral = peripheral
            self.sensorTagPeripheral.delegate = self
            self.centralManager.connect(peripheral, options: nil)
        }
        else {
            self.statusLabel.text = "Sensor Tag NOT Found"
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        self.statusLabel.text = "Discovering peripheral services"
        peripheral.discoverServices(nil)
    }
    
    func centralManager(central: CBCentralManager!, didDisconnect peripheral: CBPeripheral!, error: NSError!) {
        self.statusLabel.text = "Disconnected"
        central.scanForPeripherals(withServices: nil, options: nil)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        self.statusLabel.text = "Looking at peripheral services"
        for service in peripheral.services! {
            let thisService = service as CBService
            if service.uuid == MovementServiceUUID {
                peripheral.discoverCharacteristics(nil, for: thisService)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        self.statusLabel.text = "Enabling sensors"
        
        var enableMove = 127
        let enableBytesMove = NSData(bytes: &enableMove, length: MemoryLayout<UInt16>.size)
        
        for charateristic in service.characteristics! {
            let thisCharacteristic = charateristic as CBCharacteristic
            if thisCharacteristic.uuid == MovementDataUUID {
                self.sensorTagPeripheral.setNotifyValue(true, for: thisCharacteristic)
            }
            if thisCharacteristic.uuid == MovementConfigUUID {
                self.sensorTagPeripheral.writeValue(enableBytesMove as Data, for: thisCharacteristic, type: CBCharacteristicWriteType.withResponse)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        if (!self.startedRecord) {
            self.statusLabel.text = "Ready"
        }
        
        if characteristic.uuid == MovementDataUUID {
            // Convert NSData to array of signed 16 bit values
            let dataFromSensor = dataToSignedBytes16(value: characteristic.value! as NSData)
            if (self.startedRecord) {
                let xVal = Double(dataFromSensor[3]) * 8.0 / 32768.0
                let yVal = Double(dataFromSensor[4]) * 8.0 / 32768.0
                let zVal = Double(dataFromSensor[5]) * 8.0 / 32768.0
                
                self.perfMatrix.checkLimit(value: yVal, lowerLimit: BicepCurlMatrix.yAccOnMoveLimit)
                self.currentLateral.text = String(yVal.rounded(toPlaces: 3))
                if (abs(yVal) > BicepCurlMatrix.yAccOnMoveLimit) {
                    self.lateralStatusImage.image = UIImage(named: "Feedback_CircleRed.png")
                } else {
                    self.lateralStatusImage.image = UIImage(named: "Feedback_CircleGreen.png")
                }
                self.accData.appendData(xVal: xVal, yVal: yVal, zVal: zVal)
            }
        }
    }
    
    func dataToSignedBytes16(value : NSData) -> [Int16] {
        let count = value.length
        var array = [Int16](repeating: 0, count: count)
        value.getBytes(&array, length:count * MemoryLayout<Int16>.size)
        return array
    }
    
    func dataToSignedBytes8(value : NSData) -> [Int8] {
        let count = value.length
        var array = [Int8](repeating: 0, count: count)
        value.getBytes(&array, length:count * MemoryLayout<Int8>.size)
        return array
    }
    
}

