////
////  ParsingExamplesFileOperation.swift
////  Services
////
////  Created by Anton Tkalikov on 02.06.2020.
////  Copyright © 2020 Anton Tkalikov. All rights reserved.
////
//
//import Foundation
//
//class ParsingExamplesFileOperation: AsyncOperation {
//    let parser: ExamplesFileParser
//    var path: URL?
//    
//    init(parser: ExamplesFileParser) {
//        self.parser = parser
//    }
//    
//    override func main() {
//        guard let path = path else { return }
//        parser.parse(fileAt: path)
//        finish()
//    }
//}
