//
//  BLEManager.swift
//  BuildButton
//
//  Created by Dominik Kapusta on 23/12/2017.
//  Copyright © 2017 Base. All rights reserved.
//

import CoreBluetooth

protocol BLEManagerDelegate: class {
    func didStartScanningForButton(_ manager: BLEManager)
    func didStopScanningForButton(_ manager: BLEManager)
    func buttonDidConnect(_ manager: BLEManager)
    func buttonDidDisconnect(_ manager: BLEManager)
    func buttonPushed(_ manager: BLEManager)
    func buttonDidFinishTask(_ manager: BLEManager)
}

class BLEManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {

    unowned var delegate: BLEManagerDelegate

    var buttonDidTrigger: ((BLEManager) -> Void)? = nil
    
//    static let shared = BLEManager()
    
    private var peripheral: CBPeripheral? = nil
    private var centralManager: CBCentralManager
    private var services: [CBService] = []
    private var idleCharacteristic: CBCharacteristic? = nil

    func notifyFinishedTask() {
        setIdle()
        delegate.buttonDidFinishTask(self)
    }
    
    @discardableResult
    func startScanningForButton() -> Bool {
        if centralManager.state == .poweredOn {
            let serviceUUID = CBUUID(string: "00FF")
            centralManager.scanForPeripherals(withServices: [serviceUUID], options: nil)
            delegate.didStartScanningForButton(self)
            return true
        }
        return false
    }
    
    func setIdle() {
        if let idle = idleCharacteristic, let peripheral = peripheral {
            var data = Data()
            data.append(contentsOf: [1])
            peripheral.writeValue(data, for: idle, type: .withResponse)
        }
    }
    
    init(delegate: BLEManagerDelegate) {
        self.delegate = delegate
        centralManager = CBCentralManager(delegate: nil, queue: nil)
        super.init()
        centralManager.delegate = self
    }
    
    deinit {
        centralManager.stopScan()
    }
    
    // MARK: - CBCentralManagerDelegate
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("state: \(central.state.rawValue)")
        startScanningForButton()
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if peripheral.identifier.uuidString == "C338320C-F501-4537-8F80-D2BBF0469FFA" {
            print("central manager did discover peripheral: \(peripheral)")
            self.peripheral = peripheral
            peripheral.delegate = self
            central.connect(peripheral, options: nil)
            central.stopScan()
            delegate.didStopScanningForButton(self)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("did connect!")
        peripheral.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("did disconnect!")
        delegate.buttonDidDisconnect(self)
        startScanningForButton()
    }
    
    // MARK: - CBPeripheralDelegate
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            print("did discover services: \(services)")
            self.services = services
            for service in services {
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("characteristics: \(service.characteristics!)")
        if let notifiable = service.characteristics?.filter({$0.properties.contains(.notify)}) {
            notifiable.forEach { peripheral.setNotifyValue(true, for: $0) }
        }
        idleCharacteristic = service.characteristics?.first { $0.properties.contains(.write) }
        setIdle()
        delegate.buttonDidConnect(self)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        print("didWriteValueForCharacteristic: \(characteristic)")
        print("characteristic.value: \(String(describing: characteristic.value))")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("didUpdateValueForCharacteristic: \(characteristic)")
        print("properties: \(characteristic.properties.rawValue))")
//        let data = characteristic.value!
//        let string = String(bytes: data, encoding: .ascii)
//        print("value: \(string ?? "brak")")
        print("error: \(String(describing: error))")

        delegate.buttonPushed(self)
        buttonDidTrigger?(self)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        print("didUpdateNotificationState: \(characteristic.isNotifying)")
    }

}
