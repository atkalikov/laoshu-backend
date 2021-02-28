////
////  ExamplesParsingService.swift
////  Services
////
////  Created by Anton Tkalikov on 02.06.2020.
////  Copyright © 2020 Anton Tkalikov. All rights reserved.
////
//
//import Foundation
//import LaoshuModels
//
//public protocol ExamplesParsingService: AnyObject {
//    var delegate: ExamplesParsingServiceDelegate? { get set }
//    var isParsing: Bool { get }
//    
//    func parseExamples(at path: URL,
//                       completion: ((Result<Bool, Error>) -> Void)?)
//}
//
//public protocol ExamplesParsingServiceDelegate: AnyObject {
//    func didChangeParsingExamples(progress: Double)
//    func didParse(examples: [Example])
//}
//
//final class ExamplesParsingServiceImpl: ExamplesParsingService {
//    private let assembler: Assembler
//    private let operationQueue: OperationQueue
//    weak var delegate: ExamplesParsingServiceDelegate?
//    var isParsing: Bool = false
//    
//    init(operationQueue: OperationQueue) {
//        self.operationQueue = operationQueue
//        self.assembler = Assembler.services
//    }
//    
//    func parseExamples(at path: URL,
//                       completion: ((Result<Bool, Error>) -> Void)?) {
//        isParsing = true
//        operationQueue.cancelAllOperations()
//        
//        var progress: Double = .zero
//        var timer: Timer?
//        
//        let parser = assembler.resolver.resolve(ExamplesFileParser.self)
//        let operation = ParsingExamplesFileOperation(parser: parser!)
//            
//        operation.path = path
//        operation.parser
//            .onParsingProgress { prog in DispatchQueue.main.async { progress = prog }  }
//            .onParsingExamples { [weak delegate] in delegate?.didParse(examples: $0) }
//            .onParsingComplete { [weak self] in
//                switch $0 {
//                case .success:
//                    DispatchQueue.main.async {
//                        self?.isParsing = false
//                        timer?.invalidate()
//                        completion?(.success(true))
//                    }
//                case .failure(let error):
//                    self?.operationQueue.cancelAllOperations()
//                    DispatchQueue.main.async {
//                        timer?.invalidate()
//                        self?.isParsing = false
//                        completion?(.failure(error))
//                    }
//                }
//        }
//        
//        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak delegate] _ in
//            DispatchQueue.main.async {
//                delegate?.didChangeParsingExamples(progress: progress)
//            }
//        }
//        
//        operationQueue.addOperation(operation)
//    }
//}
