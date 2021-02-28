import Vapor
import Queues
import LaoshuModels

protocol ParsingService {
    func parseDictionary(on context: QueueContext, url: URL, type: DictionaryType) -> EventLoopFuture<Void>
    func parseSynonyms(on context: QueueContext, url: URL) -> EventLoopFuture<Void>
    func parseAntonyms(on context: QueueContext, url: URL) -> EventLoopFuture<Void>
    func parseExamples(on context: QueueContext, url: URL) -> EventLoopFuture<Void>
}

struct ParsingServiceImpl: ParsingService {
    private let dictionaryParsingService: DictionaryParsingService
    private let antonymsParsingService: AntonymsParsingService
    private let synonymsParsingService: SynonymsParsingService
    private let examplesParsingService: ExamplesParsingService
    
    init(dictionaryParsingService: DictionaryParsingService,
         antonymsParsingService: AntonymsParsingService,
         synonymsParsingService: SynonymsParsingService,
         examplesParsingService: ExamplesParsingService) {
        self.dictionaryParsingService = dictionaryParsingService
        self.antonymsParsingService = antonymsParsingService
        self.synonymsParsingService = synonymsParsingService
        self.examplesParsingService = examplesParsingService
    }
    
    func parseDictionary(on context: QueueContext, url: URL, type: DictionaryType) -> EventLoopFuture<Void> {
        dictionaryParsingService.parseDictionary(on: context, url: url, type: type)
    }
    
    func parseSynonyms(on context: QueueContext, url: URL) -> EventLoopFuture<Void> {
        synonymsParsingService.parseSynonyms(on: context, url: url)
    }
    
    func parseAntonyms(on context: QueueContext, url: URL) -> EventLoopFuture<Void> {
        antonymsParsingService.parseAntonyms(on: context, url: url)
    }
    
    func parseExamples(on context: QueueContext, url: URL) -> EventLoopFuture<Void> {
        examplesParsingService.parseExamples(on: context, url: url)
    }
}

extension Application {
    var parsingService: ParsingService {
        ParsingServiceImpl(
            dictionaryParsingService: DictionaryParsingServiceImpl(logger: logger),
            antonymsParsingService: AntonymsParsingServiceImpl(),
            synonymsParsingService: SynonymsParsingServiceImpl(),
            examplesParsingService: ExamplesParsingServiceImpl(logger: logger)
        )
    }
}
