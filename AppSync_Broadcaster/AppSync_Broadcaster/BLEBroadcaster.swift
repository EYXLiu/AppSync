//
//  BLEBroadcaster.swift
//  AppSync_Broadcaster
//
//  Created by Evan Liu on 2026-03-23.
//

import CoreBluetooth

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
        let packet = SyncPacket(timestamp: Date().timeIntervalSince1970, event: 0)
        
        guard let data = try? JSONEncoder().encode(packet) else { return }
        
        let success = peripheralManager.updateValue(
            data,
            for: syncCharacteristic,
            onSubscribedCentrals: nil
        )

        if !success {
            print("Queue full")
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager,
                           didReceiveWrite requests: [CBATTRequest]) {
        for request in requests {
                guard let data = request.value else { continue }

                do {
                    let packet = try JSONDecoder().decode(SyncPacket.self, from: data)
                    print(packet.timestamp)
                } catch {
                    print(error)
                }

                peripheralManager.respond(to: request, withResult: .success)
            }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager,
                           didReceiveRead request: CBATTRequest) {
        
    }
}
