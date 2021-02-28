//
//  DictionaryParsingService.swift
//  Services
//
//  Created by Anton Tkalikov on 27.05.2020.
//  Copyright © 2020 Anton Tkalikov. All rights reserved.
//

import Vapor
import Queues
import LaoshuModels

public protocol DictionaryParsingService: AnyObject {
    var isParsing: Bool { get }

    func parseDictionary(
        on context: QueueContext,
        url: URL,
        type: DictionaryType
    ) -> EventLoopFuture<Void>
}

final class DictionaryParsingServiceImpl: DictionaryParsingService {
    var isParsing: Bool = false
    
    func parseDictionary(
        on context: QueueContext,
        url: URL,
        type: DictionaryType
    ) -> EventLoopFuture<Void> {
        let promise = context.eventLoop.makePromise(of: Void.self)
        
        isParsing = true

        let parser = context.application
            .dictionaryFileParser(for: type)
            .onParsingDirectives { print("did parse dirictives: \($0)") }
            .onParsingWords {
                let models = $0.map { word in WordModel(word: word) }
                models.forEach { model in
                    context.application.db.transaction { (db) in
                        model.save(on: db)
                    }
                }
            }
            .onParsingComplete { [weak self] in
                print("Complete parsing: \($0)")
                switch $0 {
                case .success:
                    self?.isParsing = false
                    promise.completeWith(.success(Void()))
                case .failure(let error):
                    self?.isParsing = false
                    promise.completeWith(.failure(error))
                }
        }

        parser.parse(fileAt: url)
        promise.succeed(Void())
        return promise.futureResult
    }
}

extension Request {
    var dictionaryParsingService: DictionaryParsingService {
        return DictionaryParsingServiceImpl()
    }
}
