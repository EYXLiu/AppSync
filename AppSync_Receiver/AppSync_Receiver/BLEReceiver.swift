//
//  BLEReceiver.swift
//  AppSync_Receiver
//
//  Created by Evan Liu on 2026-03-23.
//

import CoreBluetooth
import SwiftUI
import Combine

class BLEReceiver: NSObject, ObservableObject, CBCentralManagerDelegate {
    var central: CBCentralManager!
    
    override init() {
        super.init()
        central = CBCentralManager(delegate: self, queue: nil)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            let serviceUUID = CBUUID(string: "12345678-1234-1234-1234-123456789ABC")
            central.scanForPeripherals(withServices: [serviceUUID])
        }
    }
    
    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any],
                        rssi RSSI: NSNumber) {

        if let uuids = advertisementData[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID] {
            for uuid in uuids {
                print("Received UUID:", uuid)
            }
        }
    }
}
