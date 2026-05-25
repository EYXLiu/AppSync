//
//  BLEBroadcaster.swift
//  AppSync_Broadcaster
//
//  Created by Evan Liu on 2026-03-23.
//

import CoreBluetooth
import AppSync_Shared

class BLEBroadcaster: NSObject, CBPeripheralManagerDelegate {
    var peripheralManager: CBPeripheralManager!
    
    let serviceUUID = BLEUUIDs.service

    let characteristicUUID = BLEUUIDs.syncCharacteristic
    
    var syncCharacteristic: CBMutableCharacteristic!
    
    var counter = 1
    
    override init() {
        super.init()
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            setupSync()
        }
    }
    
    func setupSync() {
        syncCharacteristic = CBMutableCharacteristic(
            type: characteristicUUID,
            properties: [.notify, .read, .write],
            value: nil,
            permissions: [.readable, .writeable]
        )
        
        let service = CBMutableService(type: serviceUUID, primary: true)
        service.characteristics = [syncCharacteristic]
        
        peripheralManager.add(service)
        peripheralManager.startAdvertising([
            CBAdvertisementDataServiceUUIDsKey: [serviceUUID]
        ])
        
        startBroadcasting()
    }
    
    func startBroadcasting() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.sendPacket()
        }
    }
    
    func sendPacket() {
        let packet = SyncPacket(sequence: UInt32(counter), timestamp: Date().timeIntervalSince1970)
        
        guard let data = try? JSONEncoder().encode(packet) else { return }
        
        let success = peripheralManager.updateValue(
            data,
            for: syncCharacteristic,
            onSubscribedCentrals: nil
        )

        if !success {
            print("Queue full")
        }
        
        counter = (counter % 5) + 1
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager,
                           didReceiveWrite requests: [CBATTRequest]) {
        
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager,
                           didReceiveRead request: CBATTRequest) {
        
    }
}
