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
import CoreBluetooth

class SportIntroController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {

    var centralManager : CBCentralManager!
    var sensorTagPeripheral : CBPeripheral!
    
    let MovementServiceUUID = CBUUID(string: "F000AA80-0451-4000-B000-000000000000")
    let MovementDataUUID = CBUUID(string: "F000AA81-0451-4000-B000-000000000000")
    let MovementConfigUUID = CBUUID(string: "F000AA82-0451-4000-B000-000000000000")
    var xArray = Array<Double>()
    var yArray = Array<Double>()
    var zArray = Array<Double>()
    
    //MARK: LABEL & BUTTON SET UP
    var sportnameLabel: UILabel = {
        let label = UILabel()
        label.text = "Sportname"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    
    var statusLabel: UILabel = {
        let label = UILabel()
        label.text = "connect status"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    
    //MARK: START BUTTON
    var starttime = 0.0
    
    let startsportButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Start Training", for: .normal)
        button.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handleStart), for: .touchUpInside)
        button.isEnabled = true
        return button
    }()
    
    @objc func handleStart(){
        if statusLabel.text != "Connected" {
            startsportButton.isEnabled = false
        }
        starttime = Date().timeIntervalSince1970
        endsportButton.isEnabled = true
        xArray = []
        yArray = []
        zArray = []
    }
    
    // MARK: END BUTTON
    let endsportButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("End Training", for: .normal)
        button.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handleEnd), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    @objc func handleEnd(){
        //save data
        saveData()
        //open the data analysis page
        let alert = UIAlertController(title: "Data Saved!", message:"Would you like to go to the analysis page?", preferredStyle: .alert)
        
        let action1 = UIAlertAction(title: "Sure", style: .default) { (action:UIAlertAction) in
            let dataAnalysisController = DataAnalysisController()
            dataAnalysisController.starttime = self.starttime
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
            "x_value": self.xArray,
            "y_value": self.yArray,
            "z_value": self.zArray,
            "starttime": starttime,
            "endtime": Date().timeIntervalSince1970]){ err in
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
        
        view.addSubview(sportnameLabel)
        sportnameLabel.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 150)
        
        view.addSubview(statusLabel)
        statusLabel.anchor(top: sportnameLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
        
        navigationController?.isNavigationBarHidden = true
        
        view.backgroundColor = .white
        
        view.addSubview(startsportButton)
        startsportButton.anchor(top: statusLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
        
        view.addSubview(endsportButton)
        endsportButton.anchor(top: startsportButton.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
        
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
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
    
    //MARK: GET DATA (HAS A PROBLEM HERE)
    // I'm thinking to start record when start button click, and I'm not sure where to put this didSet{},
    // and now I just set array back to nil in the start button. I'm not sure there will be another way to do this
    var xVal = 0.0 {
        didSet{
            xArray.append(xVal)
        }
    }
    var yVal = 0.0 {
        didSet{
            yArray.append(yVal)
        }
    }
    var zVal = 0.0 {
        didSet{
            zArray.append(zVal)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        self.statusLabel.text = "Connected"
        
        if characteristic.uuid == MovementDataUUID {
            // Convert NSData to array of signed 16 bit values
            let dataFromSensor = dataToSignedBytes16(value: characteristic.value! as NSData)
            xVal = Double(dataFromSensor[3]) * 2.0 / 32768.0
            yVal = Double(dataFromSensor[4]) * 2.0 / 32768.0
            zVal = Double(dataFromSensor[5]) * 2.0 / 32768.0
            
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
