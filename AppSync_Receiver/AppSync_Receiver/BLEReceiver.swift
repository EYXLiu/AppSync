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
    var peripheral: CBPeripheral?
    var syncCharacteristic: CBCharacteristic?
    
    let serviceUUID = BLEUUIDs.service
    let characteristicUUID = BLEUUIDs.syncCharacteristic
    
    @Published var message: String = "Waiting..."
    
    override init() {
        super.init()
        central = CBCentralManager(delegate: self, queue: nil)
    }
    
    // called when bluetooth turns on/off, checks if bluetooth is avaliable
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            central.scanForPeripherals(withServices: [serviceUUID])
        }
    }
    
    // called when bluetooth device is discovered during scanning, connects and stops scanning
    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any],
                        rssi RSSI: NSNumber) {

        self.peripheral = peripheral
        self.peripheral?.delegate = self

        central.stopScan()
        central.connect(peripheral)
    }
    
    // called after successfully connecting with a bluetooth device
    func centralManager(_ central: CBCentralManager,
                        didConnect peripheral: CBPeripheral) {

        peripheral.discoverServices([serviceUUID])
    }
    
    // called after services are discovered
    func peripheral(_ peripheral: CBPeripheral,
                    didDiscoverServices error: Error?) {

        guard let services = peripheral.services else { return }

        for service in services {
            peripheral.discoverCharacteristics([BLEUUIDs.syncCharacteristic], for: service)
        }
    }
    
    // called after characteristics are found
    func peripheral(_ peripheral: CBPeripheral,
                    didDiscoverCharacteristicsFor service: CBService,
                    error: Error?) {

        guard let characteristics = service.characteristics else { return }

        for characteristic in characteristics {
            self.syncCharacteristic = characteristic
            peripheral.setNotifyValue(true, for: characteristic)
        }
    }
    
    // called when data is updated (main receive data function)
    func peripheral(_ peripheral: CBPeripheral,
                    didUpdateValueFor characteristic: CBCharacteristic,
                    error: Error?) {

        guard let data = characteristic.value,
              let packet = try? JSONDecoder().decode(
                SyncPacket.self, from: data
              ) else { return }

        DispatchQueue.main.async {
            self.message = String(packet.timestamp)
            self.sendPacket()
        }
    }
    
    // called when service itself is modified
    func peripheral(_ peripheral: CBPeripheral,
                    didModifyServices invalidatedServices: [CBService]) {
        // handle service change
    }
    
    func sendPacket() {
        guard let peripheral = peripheral,
              let characteristic = syncCharacteristic else { return }
        
        let packet = SyncPacket(timestamp: Date().timeIntervalSince1970, event: 0)
        
        guard let data = try? JSONEncoder().encode(packet) else { return }
        
        peripheral.writeValue(
            data,
            for: characteristic,
            type: .withResponse
        )
    }
}
