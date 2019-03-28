
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
    var mode: Int!
    
    var timer:Timer?
    var timeLeft = 3
    var countDownAlert: UIAlertController!
    
    var startedRecord = false
    
    var bannerImage: UIImage!
    var introImage: UIImage!
    var perfMatrix: PerformanceMatrix!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var startsportButton: UIButton!
    
    @IBOutlet weak var endsportButton: UIButton!
    
    //MARK: START BUTTON
    @IBAction func startButtonTapped(_ sender: Any) {
        if statusLabel.text != "Ready" {
            startsportButton.isEnabled = false
        }
        
        countDownAlert = UIAlertController(title: "GET READY!", message: "3", preferredStyle: .alert)
        
        let myString  = "GET READY\n\n"
        var myMutableString = NSMutableAttributedString()
        myMutableString = NSMutableAttributedString(string: myString as String, attributes: [NSAttributedString.Key.font:UIFont(name: "Georgia", size: 25.0)!])
        myMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.gray, range: NSRange(location:0,length:myString.count))
        countDownAlert.setValue(myMutableString, forKey: "attributedTitle")
        
        let message = "3"
        var messageMutableString = NSMutableAttributedString()
        messageMutableString = NSMutableAttributedString(string: message as String, attributes: [NSAttributedString.Key.font:UIFont(name: "Georgia", size: 35.0)!])
        messageMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.red, range: NSRange(location:0,length:message.count))
        countDownAlert.setValue(messageMutableString, forKey: "attributedMessage")
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction) in
            self.countDownAlert.dismiss(animated: true, completion: nil)
        }
        countDownAlert.addAction(cancelAction)
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(countDown), userInfo: nil, repeats: true)
        self.present(countDownAlert, animated: true, completion: nil)
    }

 

    @objc func countDown() {
        timeLeft -= 1
        
        let message = "\(timeLeft)" 
        var messageMutableString = NSMutableAttributedString()
        messageMutableString = NSMutableAttributedString(string: message as String, attributes: [NSAttributedString.Key.font:UIFont(name: "Georgia", size: 35.0)!])
        messageMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.red, range: NSRange(location:0,length: message.count))
        countDownAlert.setValue(messageMutableString, forKey: "attributedMessage")
        
        //countDownAlert.message = "\(timeLeft)"
    
        if timeLeft <= 0 {
            timer!.invalidate()
            timer = nil
            countDownAlert.dismiss(animated: true, completion: nil)
            
            // list of sounds: https://github.com/TUNER88/iOSSystemSoundsLibrary
            let systemSoundID: SystemSoundID = 1057
            AudioServicesPlaySystemSound(systemSoundID)
            setUpRecordingData()
            self.startedRecord = true
        }
    }
    
    func setUpRecordingData() {
        endsportButton.isEnabled = true
        accData = AccData(startTime: Date().timeIntervalSince1970)
        statusLabel.text = "Recording Data"
    }

    //MARK: END BUTTON
    @IBAction func endButtonTapped(_ sender: Any) {
        //save data
        disconnectSensorTag()
        self.statusLabel.text = "Stopped Recording"
        self.startedRecord = false
        self.accData.endTime = Date().timeIntervalSince1970
        self.accData.cleanUpNoise()
        
        self.lateralAccAvg = self.accData.calCulateAvg(mode: self.mode)
        self.lateralStabilityScore = self.accData.calculateScore(mode: self.mode)
        self.tampoAvg = self.accData.calculateAvgTampo(mode: self.mode)
        
        saveData()
        //open the data analysis page
        let alert = UIAlertController(title: "Data Saved!", message:"Would you like to go to the analysis page?", preferredStyle: .alert)
        
        let action1 = UIAlertAction(title: "Sure", style: .default) { (action:UIAlertAction) in
            let dataAnalysisController = DataAnalysisController()
            dataAnalysisController.accData = self.accData
            dataAnalysisController.mode = self.mode
            dataAnalysisController.lateralAccAvg = self.lateralAccAvg
            dataAnalysisController.lateralStabilityScore = self.lateralStabilityScore
            self.performSegue(withIdentifier: "goToDataPage", sender: self)
        }
        
        let action2 = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction) in
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(action1)
        alert.addAction(action2)
        
        self.present(alert, animated: true, completion: nil)
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
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
  
 
    //MARK: IMPLEMENT SENSOR
    func disconnectSensorTag() {
        self.centralManager.cancelPeripheralConnection(self.sensorTagPeripheral)
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
        
        self.statusLabel.text = "Ready"
        
        if characteristic.uuid == MovementDataUUID {
            // Convert NSData to array of signed 16 bit values
            let dataFromSensor = dataToSignedBytes16(value: characteristic.value! as NSData)
            if (self.startedRecord) {
                let xVal = Double(dataFromSensor[3]) * 8.0 / 32768.0
                let yVal = Double(dataFromSensor[4]) * 8.0 / 32768.0
                let zVal = Double(dataFromSensor[5]) * 8.0 / 32768.0
                
                if (self.accData.idleDetection(mode: 3)) {
                    self.startedRecord = false
                }
                
                self.perfMatrix.checkLimit(value: yVal, lowerLimit: BicepCurlMatrix.yAccOnMoveLimit)
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
