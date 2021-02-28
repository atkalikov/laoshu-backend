//
//  ParsingWordStrategy.swift
//  Parser
//
//  Created by Anton Tkalikov on 23.05.2020.
//  Copyright © 2020 atkalikov. All rights reserved.
//

import Foundation
import LaoshuModels

public protocol ParsingWordStrategy {
    func parse(from string: String) -> Word?
}
