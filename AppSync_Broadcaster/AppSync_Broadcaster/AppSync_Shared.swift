//
//  AppSync_Shared.swift
//  AppSync_Broadcaster
//
//  Created by Evan Liu on 2026-05-25.
//
// I WILL ADDRESS THIS IN THE FUTURE BUT THIS MIGHT BE AN XCODE LIMITATION THAT I CAN'T USE A CUSTOM LIBRARY IN TWO XCODE INSTANCES

//
// UUIDs.swift
//

// legacy module, relax concurrency checks
@preconcurrency import CoreBluetooth

// immutable, safe to share accross threads in practice
public enum BLEUUIDs {
    public static let service = CBUUID(string: "12345678-1234-1234-1234-123456789ABC")
    public  static let syncCharacteristic = CBUUID(string: "87654321-4321-4321-4321-CBA987654321")
}

//
// Packets.swift
//

public struct SyncPacket: Codable {
    public let timestamp: Double
    public var event: UInt8

    public init(timestamp: Double, event: UInt8) {
        self.timestamp = timestamp
        self.event = event
    }
}
