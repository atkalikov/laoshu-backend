//
//  String+Extensions.swift
//  Parser
//
//  Created by Tkalikov Anton on 22.05.2020.
//  Copyright © 2020 atkalikov. All rights reserved.
//

import Foundation

extension String {    
    func isIncludeChinese() -> Bool {
        for ch in self.unicodeScalars {
            if (0x4e00 < ch.value  && ch.value < 0x9fff) { return true }
        }
        return false
    }
    
    func transformToPinyin() -> String {
        let stringRef = NSMutableString(string: self) as CFMutableString
        CFStringTransform(stringRef,nil, kCFStringTransformToLatin, false)
        let pinyin = stringRef as String
        
        return pinyin
    }
}
