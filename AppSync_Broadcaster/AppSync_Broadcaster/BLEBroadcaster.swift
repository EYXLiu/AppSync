//
//  BLEBroadcaster.swift
//  AppSync_Broadcaster
//
//  Created by Evan Liu on 2026-03-23.
//
//  central

import CoreBluetooth

class BLEBroadcaster: NSObject, CBPeripheralManagerDelegate {
    var peripheralManager: CBPeripheralManager!
    var syncCharacteristic: CBMutableCharacteristic!
    
    let serviceUUID = BLEUUIDs.service
    let characteristicUUID = BLEUUIDs.syncCharacteristic
    
    
    override init() {
        super.init()
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    // called when the peripheral starts
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
    }
    
    // called when the peripheral receives a write update
    func peripheralManager(_ peripheral: CBPeripheralManager,
                           didReceiveWrite requests: [CBATTRequest]) {
        for request in requests {
                guard let data = request.value else { continue }

                do {
                    let packet = try JSONDecoder().decode(Packet.self, from: data)
                    switch packet.type {
                    case .syncRequest:
                        handleSyncRequest(packet: packet)
                    case .syncResponse:
                        // shouldn't ever receive a response, should only send
                        print(packet)
                        break
                    case .scheduledEvent:
                        handleScheduledEvent(packet: packet)
                    }
                } catch {
                    print(error)
                }

                peripheralManager.respond(to: request, withResult: .success)
            }
    }
    
    // called when the peripheral receives a read request
    func peripheralManager(_ peripheral: CBPeripheralManager,
                           didReceiveRead request: CBATTRequest) {
        
    }
    
    // receive a packet of type SyncRequest, expects a packet of type SyncResponse
    func handleSyncRequest(packet: Packet) {
        let t2 = getTimeNow()
        
        let t1 = packet.t1
        let sequence = packet.sequence
        
        let response = Packet(type: .syncResponse, sequence: sequence, t1: t1, t2: t2, t3: getTimeNow())
        sendPacket(packet: response)
    }
    
    // used to send scheduled events
    func handleScheduledEvent(packet: Packet) {
        
    }
    
    func sendPacket(packet: Packet) {
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
}
