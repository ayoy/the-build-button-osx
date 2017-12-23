//
//  BLEManager.swift
//  BuildButton
//
//  Created by Dominik Kapusta on 23/12/2017.
//  Copyright © 2017 Base. All rights reserved.
//

import CoreBluetooth

class BLEManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    var peripheral: CBPeripheral? = nil
    var centralManager: CBCentralManager? = nil
    var services: [CBService] = []
    var idleCharacteristic: CBCharacteristic? = nil
    
    var buttonDidTrigger: ((BLEManager) -> Void)? = nil

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    deinit {
        centralManager?.stopScan()
    }
    
    func notifyFinishedTask() {
        setIdle()
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("state: \(central.state.rawValue)")
        if central.state == .poweredOn {
            centralManager?.scanForPeripherals(withServices: nil, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if peripheral.identifier.uuidString == "C338320C-F501-4537-8F80-D2BBF0469FFA" {
            print("central manager did discover peripheral: \(peripheral)")
            self.peripheral = peripheral
            peripheral.delegate = self
            central.connect(peripheral, options: nil)
            central.stopScan()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("did connect!")
        peripheral.discoverServices(nil)
    }
    
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
    }
    
    func setIdle() {
        if let idle = idleCharacteristic, let peripheral = peripheral {
            var data = Data()
            data.append(contentsOf: [1])
            peripheral.writeValue(data, for: idle, type: .withResponse)
        }
    }
    
    //    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
    //        print("didDiscoverDescriptorsFor: \(characteristic)")
    //        if let descriptor = characteristic.descriptors?.first {
    //            print(descriptor)
    //        }
    //    }
    
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

        buttonDidTrigger?(self)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        print("didUpdateNotificationState: \(characteristic.isNotifying)")
    }

}
