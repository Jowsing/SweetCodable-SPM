//
//  File.swift
//  
//
//  Created by jowsing on 2024/4/15.
//

import Foundation

public struct AnyCodingKey: CodingKey {
    public var stringValue: String
    
    public init?(stringValue: String) {
        self.stringValue = stringValue
    }
    
    public var intValue: Int?
    
    public init?(intValue: Int) {
        self.intValue = intValue
        self.stringValue = String(intValue)
    }
}
