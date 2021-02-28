////
////  ParsingSynonymsFileOperation.swift
////  Services
////
////  Created by Anton Tkalikov on 03.06.2020.
////  Copyright © 2020 Anton Tkalikov. All rights reserved.
////
//
//import Foundation
//
//class ParsingSynonymsFileOperation: AsyncOperation {
//    let parser: SynonymsFileParser
//    var path: URL?
//
//    init(parser: SynonymsFileParser) {
//        self.parser = parser
//    }
//
//    override func main() {
//        guard let path = path else { return }
//        parser.parse(fileAt: path)
//        finish()
//    }
//}
