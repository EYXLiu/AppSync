//
//  BLEReceiver.swift
//  AppSync_Receiver
//
//  Created by Evan Liu on 2026-03-23.
//

import CoreBluetooth
import SwiftUI
import Combine

class BLEReceiver: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    var central: CBCentralManager!
    @Published var message: String = "Waiting..."
    
    var peripheral: CBPeripheral?
    
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

        self.peripheral = peripheral
        self.peripheral?.delegate = self

        central.stopScan()
        central.connect(peripheral)
    }
    
    func centralManager(_ central: CBCentralManager,
                        didConnect peripheral: CBPeripheral) {

        let serviceUUID = CBUUID(string: "12345678-1234-1234-1234-123456789ABC")
        peripheral.discoverServices([serviceUUID])
    }
    
    func peripheral(_ peripheral: CBPeripheral,
                    didDiscoverServices error: Error?) {

        guard let services = peripheral.services else { return }

        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral,
                    didDiscoverCharacteristicsFor service: CBService,
                    error: Error?) {

        guard let characteristics = service.characteristics else { return }

        for characteristic in characteristics {
            peripheral.setNotifyValue(true, for: characteristic)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral,
                    didUpdateValueFor characteristic: CBCharacteristic,
                    error: Error?) {

        guard let data = characteristic.value,
              let string = String(data: data, encoding: .utf8) else { return }

        DispatchQueue.main.async {
            self.message = string
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral,
                    didModifyServices invalidatedServices: [CBService]) {
        // handle service change
    }
}
