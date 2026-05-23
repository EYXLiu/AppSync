//
//  BLEBroadcaster.swift
//  AppSync_Broadcaster
//
//  Created by Evan Liu on 2026-03-23.
//

import CoreBluetooth

class BLEBroadcaster: NSObject, CBPeripheralManagerDelegate {
    var peripheralManager: CBPeripheralManager!
    
    let serviceUUID = CBUUID(string: "12345678-1234-1234-1234-123456789ABC")

    let characteristicUUID = CBUUID(string: "87654321-4321-4321-4321-CBA987654321")
    
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
            properties: [.notify],
            value: nil,
            permissions: [.readable]
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
        let value = "\(counter)"
        
        guard let data = value.data(using: .utf8) else { return }
        
        peripheralManager.updateValue(data, for: syncCharacteristic, onSubscribedCentrals: nil)
        
        counter = (counter % 5) + 1
    }
}
