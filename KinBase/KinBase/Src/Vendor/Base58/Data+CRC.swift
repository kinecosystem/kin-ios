//
//  Data+CRC.swift
//  stellarsdk
//
//  Created by Razvan Chelemen on 29/01/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

extension Data {
    
    func crc16() -> UInt16 {
        return CRCCCITTXModem(self)
    }
    
    func crc16Data() -> Data {
        var crc = crc16()
        let crcData = Data(bytes: &crc, count: MemoryLayout.size(ofValue: crc))
        
        var data = self
        data.append(crcData)
        
        return data
    }
    
    /**
     CRC-CCITT (XModem)
     [http://www.lammertbies.nl/comm/info/crc-calculation.html]()
     
     [http://web.mit.edu/6.115/www/amulet/xmodem.htm]()
     */
    private func CRCCCITTXModem(_ bytes: Data) -> UInt16 {
        var crc: UInt16 = 0
        
        for byte in bytes {
            crc ^= UInt16(byte) << 8
            
            for _ in 0..<8 {
                if crc & 0x8000 != 0 {
                    crc = crc << 1 ^ 0x1021
                } else {
                    crc = crc << 1
                }
            }
        }
        
        return crc
    }
}
