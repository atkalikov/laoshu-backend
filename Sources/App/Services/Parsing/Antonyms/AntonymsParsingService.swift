////
////  AntonymsParsingService.swift
////  Services
////
////  Created by Anton Tkalikov on 03.06.2020.
////  Copyright © 2020 Anton Tkalikov. All rights reserved.
////
//
//import Foundation
//import LaoshuModels
//
//public protocol AntonymsParsingService: AnyObject {
//    var delegate: AntonymsParsingServiceDelegate? { get set }
//    var isParsing: Bool { get }
//    
//    func parseAntonyms(at path: URL,
//                       completion: ((Result<Bool, Error>) -> Void)?)
//}
//
//public protocol AntonymsParsingServiceDelegate: AnyObject {
//    func didChangeParsingAntonyms(progress: Double)
//    func didParse(antonyms: [Antonym])
//}
//
//final class AntonymsParsingServiceImpl: AntonymsParsingService {
//    private let assembler: Assembler
//    private let operationQueue: OperationQueue
//    weak var delegate: AntonymsParsingServiceDelegate?
//    var isParsing: Bool = false
//    
//    init(operationQueue: OperationQueue) {
//        self.operationQueue = operationQueue
//        self.assembler = Assembler.services
//    }
//    
//    func parseAntonyms(at path: URL,
//                       completion: ((Result<Bool, Error>) -> Void)?) {
//        isParsing = true
//        operationQueue.cancelAllOperations()
//        
//        var progress: Double = .zero
//        var timer: Timer?
//        
//        let parser = assembler.resolver.resolve(AntonymsFileParser.self)
//        let operation = ParsingAntonymsFileOperation(parser: parser!)
//        
//        operation.path = path
//        operation.parser
//            .onParsingProgress { prog in DispatchQueue.main.async { progress = prog }  }
//            .onParsingAntonyms { [weak delegate] in delegate?.didParse(antonyms: $0) }
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
//                delegate?.didChangeParsingAntonyms(progress: progress)
//            }
//        }
//        
//        operationQueue.addOperation(operation)
//    }
//}
