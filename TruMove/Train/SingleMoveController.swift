
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
    
    var timer:Timer?
    var timeLeft = 3
    var countDownAlert: UIAlertController!
    
    var startedRecord = false
    
    var bannerImage: UIImage!
    var introImage: UIImage!
    var perfMatrix: PerformanceMatrix!
    
    //MARK: LABEL & IMAGE SET UP
    
    var statusLabel: UILabel = {
        let label = UILabel()
        label.text = "Sensor connect status"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    var bannerImageView: UIImageView = {
        let biv = UIImageView()
        biv.contentMode = .scaleAspectFit
        return biv
    }()
    
    var instructImageView: UIImageView = {
        let biv = UIImageView()
        biv.contentMode = .scaleAspectFit
        return biv
    }()
    
    let startsportButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Start Training", for: .normal)
        button.backgroundColor = UIColor.green
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handleStart), for: .touchUpInside)
        button.isEnabled = true
        return button
    }()
    
    @objc func handleStart(){
        if statusLabel.text != "Ready" {
            startsportButton.isEnabled = false
        }
        
        countDownAlert = UIAlertController(title: "GET READY!", message: "3", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction) in
            self.countDownAlert.dismiss(animated: true, completion: nil)
        }
        countDownAlert.addAction(cancelAction)
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(countDown), userInfo: nil, repeats: true)
        self.present(countDownAlert, animated: true, completion: nil)
    }
    
    @objc func countDown() {
        timeLeft -= 1
        countDownAlert.message = "\(timeLeft)"
        
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
    
    // MARK: END BUTTON
    let endsportButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("End Training", for: .normal)
        button.backgroundColor = UIColor.red
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handleEnd), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    @objc func handleEnd(){
        //save data
        disconnectSensorTag()
        self.statusLabel.text = "Stopped Recording"
        self.startedRecord = false
        self.accData.endTime = Date().timeIntervalSince1970
        self.accData.cleanUpNoise()
        saveData()
        //open the data analysis page
        let alert = UIAlertController(title: "Data Saved!", message:"Would you like to go to the analysis page?", preferredStyle: .alert)
        
        let action1 = UIAlertAction(title: "Sure", style: .default) { (action:UIAlertAction) in
            let dataAnalysisController = DataAnalysisController()
            dataAnalysisController.starttime = self.accData.startTime
            dataAnalysisController.yArray = self.accData.yArray
            self.navigationController?.pushViewController(dataAnalysisController, animated: true)
        }
        
        let action2 = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction) in
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(action1)
        alert.addAction(action2)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    fileprivate func saveData(){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        Firestore.firestore().collection(uid).addDocument(data:[
            "x_value": self.accData.xArray,
            "y_value": self.accData.yArray,
            "z_value": self.accData.zArray,
            "starttime": self.accData.startTime,
            "endtime": self.accData.endTime]){ err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("user saved!")
                    
                }
        }
    }
    
    
    // MARK: VIEW DID LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPage()
        
        navigationController?.isNavigationBarHidden = false
        view.backgroundColor = .white
        
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    // MARK: SET UP UI
    fileprivate func setupPage(){
        view.addSubview(statusLabel)
        
        underNav(newView: statusLabel)
        
        bannerImageView.image = bannerImage
        view.addSubview(bannerImageView)
        bannerImageView.anchor(top: statusLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 5, paddingBottom: 0, paddingRight: 5, width: 0, height: 50)
        
        instructImageView.image = introImage
        view.addSubview(instructImageView)
        instructImageView.anchor(top: bannerImageView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: 350)
        
        view.addSubview(startsportButton)
        startsportButton.anchor(top: instructImageView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 5, paddingLeft: 25, paddingBottom: 5, paddingRight: 25, width: 0, height: 40)
        
        view.addSubview(endsportButton)
        endsportButton.anchor(top: startsportButton.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 5, paddingLeft: 25, paddingBottom: 5, paddingRight: 25, width: 0, height: 40)
    }
    
    
    fileprivate func underNav(newView: UIView){
        newView.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 11.0, *) {
            let guide = self.view.safeAreaLayoutGuide
            newView.trailingAnchor.constraint(equalTo: guide.trailingAnchor).isActive = true
            newView.leadingAnchor.constraint(equalTo: guide.leadingAnchor).isActive = true
            newView.topAnchor.constraint(equalTo: guide.topAnchor).isActive = true
            newView.heightAnchor.constraint(equalToConstant: 25).isActive = true
        } else {
            NSLayoutConstraint(item: newView,
                               attribute: .top,
                               relatedBy: .equal,
                               toItem: view, attribute: .top,
                               multiplier: 1.0, constant: 0).isActive = true
            NSLayoutConstraint(item: newView,
                               attribute: .leading,
                               relatedBy: .equal, toItem: view,
                               attribute: .leading,
                               multiplier: 1.0,
                               constant: 0).isActive = true
            NSLayoutConstraint(item: newView, attribute: .trailing,
                               relatedBy: .equal,
                               toItem: view,
                               attribute: .trailing,
                               multiplier: 1.0,
                               constant: 0).isActive = true
            
            newView.heightAnchor.constraint(equalToConstant: 25).isActive = true
        }
    }
    
    func disconnectSensorTag() {
        self.centralManager.cancelPeripheralConnection(self.sensorTagPeripheral)
    }
    
    //MARK: IMPLEMENT SENSOR
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
                let xVal = Double(dataFromSensor[3]) * 2.0 / 32768.0
                let yVal = Double(dataFromSensor[4]) * 2.0 / 32768.0
                let zVal = Double(dataFromSensor[5]) * 2.0 / 32768.0
                
                if (self.accData.idleDetection(mode: 3)) {
                    self.startedRecord = false
                }
                
                self.perfMatrix.checkLimit(value: yVal, lowerLimit: BicepCurlMatrix.yAccLimit)
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
