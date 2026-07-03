//
//  BLEReceiver.swift
//  AppSync_Receiver
//
//  Created by Evan Liu on 2026-03-23.
//
//  peripheral

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
    @Published var clock: ClockModel = ClockModel(offset: 0, rtt: 0)
    
    var counter: UInt8 = 0
    
    let mp3Player = MP3Player()
    let screenPlayer = ScreenPlayer()
    
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
        
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            self.handleSyncRequest()
        }
    }
    
    // called when data is updated (main receive data function)
    func peripheral(_ peripheral: CBPeripheral,
                    didUpdateValueFor characteristic: CBCharacteristic,
                    error: Error?) {

        guard let data = characteristic.value,
              let packet = try? JSONDecoder().decode(
                Packet.self, from: data
              ) else { return }

        switch packet.type {
        case .syncRequest:
            // shouldn't ever receive a sync request, should only send
            print(packet)
            break
        case .syncResponse:
            handleSyncResponse(packet: packet)
        case .scheduledEvent:
            handleScheduledEvent(packet: packet)
        }
    }
    
    // called when service itself is modified
    func peripheral(_ peripheral: CBPeripheral,
                    didModifyServices invalidatedServices: [CBService]) {
        // handle service change
    }
    
    // used to send a SyncRequest packet
    func handleSyncRequest() {
        let packet = Packet(type: .syncRequest, sequence: counter, t1: getTimeNow())
        sendPacket(packet: packet)
        counter = (counter + 1) % 5
    }
    
    // what happens when a sync response is received
    func handleSyncResponse(packet: Packet) {
        let t4 = getTimeNow()
        
        guard let t1 = packet.t1,
              let t2 = packet.t2,
              let t3 = packet.t3 else { return }
    
        let newOffset = ((t2 - t1) + (t3 - t4)) / 2.0
        let newRtt = (t4 - t1) - (t3 - t2)
        
        if clock.offset == 0 {
            clock.offset = newOffset
            clock.rtt = newRtt
        }
        if newRtt < clock.rtt || clock.rtt == 0 {
            clock.offset = clock.offset * 0.8 + newOffset * 0.2
            clock.rtt = newRtt
        }
    }
    
    // what happens when a scheduled event is received
    func handleScheduledEvent(packet: Packet) {
        guard let serverTime = packet.timestamp else { return }
        let adjustedServerTime = serverTime + (clock.rtt / 2.0)
        let now = getTimeNow()
        let serverNow = now + clock.offset
        let delay = adjustedServerTime - serverNow
        if delay <= 0 { return }
        switch packet.event {
        case 1:
            self.message = "flashed"
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.screenPlayer.play()
            }
        case 2:
            self.message = "playing"
            guard let fileName = packet.fileName else { return }
            self.mp3Player.update(named: fileName)
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                guard let offset = packet.offset else { return }
                self.mp3Player.play(from: offset)
            }
        case 3:
            self.message = "stopping"
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.mp3Player.stop()
                self.mp3Player.clear()
            }
        default:
            return
        }
    }
    
    func sendPacket(packet: Packet) {
        guard let peripheral = peripheral,
              let characteristic = syncCharacteristic else { return }
        
        guard let data = try? JSONEncoder().encode(packet) else { return }
        
        peripheral.writeValue(
            data,
            for: characteristic,
            type: .withResponse
        )
    }
}
