//
//  AppSync_Shared.swift
//  AppSync_Receiver
//
//  Created by Evan Liu on 2026-05-25.
//

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
    public let sequence: UInt32
    public let timestamp: Double

    public init(sequence: UInt32, timestamp: Double) {
        self.sequence = sequence
        self.timestamp = timestamp
    }
}
