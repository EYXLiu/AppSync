//
//  BLEBroadcaster.swift
//  AppSync_Broadcaster
//
//  Created by Evan Liu on 2026-03-23.
//

import CoreBluetooth

class BLEBroadcaster: NSObject, CBPeripheralManagerDelegate {
    var peripheralManager: CBPeripheralManager!
    var sequence: UInt8 = 0
    
    override init() {
        super.init()
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            startBroadcasting()
        }
    }
    
    func startBroadcasting() {
        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
            self.sendPacket()
        }
    }
    
    func sendPacket() {
        let serviceUUID = CBUUID(string: "12345678-1234-1234-1234-123456789ABC")
        let advertisement: [String: Any] = [
            CBAdvertisementDataServiceUUIDsKey: [serviceUUID]
        ]

        peripheralManager.stopAdvertising()
        peripheralManager.startAdvertising(advertisement)
    }
}
