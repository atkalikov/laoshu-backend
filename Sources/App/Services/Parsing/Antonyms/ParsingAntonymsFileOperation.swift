////
////  ParsingAntonymsFileOperation.swift
////  Services
////
////  Created by Anton Tkalikov on 03.06.2020.
////  Copyright © 2020 Anton Tkalikov. All rights reserved.
////
//
//import Foundation
//
//class ParsingAntonymsFileOperation: AsyncOperation {
//    let parser: AntonymsFileParser
//    var path: URL?
//
//    init(parser: AntonymsFileParser) {
//        self.parser = parser
//    }
//
//    override func main() {
//        guard let path = path else { return }
//        parser.parse(fileAt: path)
//        finish()
//    }
//}
