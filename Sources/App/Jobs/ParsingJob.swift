import Vapor
import Foundation
import Queues

struct ParsingJob: Job {
    typealias Payload = ConverterInputModel
    
    private let parsingService: ParsingService
    
    init(_ parsingService: ParsingService) {
        self.parsingService = parsingService
    }
    
    func dequeue(_ context: QueueContext, _ payload: ConverterInputModel) -> EventLoopFuture<Void> {
        guard let url = URL(string: payload.url) else {
            return context.eventLoop.future()
        }

        switch payload.entity {
        case .bkrs:
            return parsingService.parseDictionary(on: context, url: url, type: .bkrs, isItInitialParsing: payload.initial)
        case .bruks:
            return parsingService.parseDictionary(on: context, url: url, type: .bruks, isItInitialParsing: payload.initial)
        case .examples:
            return parsingService.parseExamples(on: context, url: url, isItInitialParsing: payload.initial)
        case .antonyms:
            return parsingService.parseAntonyms(on: context, url: url)
        case .synonyms:
            return parsingService.parseSynonyms(on: context, url: url)
        }
    }
    
    func error(_ context: QueueContext, _ error: Error, _ payload: ConverterInputModel) -> EventLoopFuture<Void> {
        return context.eventLoop.future()
    }
}
