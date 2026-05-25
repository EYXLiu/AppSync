//
//  UUIDs.swift
//  
//
//  Created by Evan Liu on 2026-05-23.
//

// legacy module, relax concurrency checks
@preconcurrency import CoreBluetooth

// immutable, safe to share accross threads in practice
public enum BLEUUIDs {
    public static let service = CBUUID(string: "12345678-1234-1234-1234-123456789ABC")
    public  static let syncCharacteristic = CBUUID(string: "87654321-4321-4321-4321-CBA987654321")
}
