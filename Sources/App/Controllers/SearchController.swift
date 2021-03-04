import Vapor
import Fluent
import LaoshuCore

final class SearchController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let searchBuilder = routes.grouped("search")
        searchBuilder.get("word", use: words(req:))
    }
    
    func words(req: Request) throws -> EventLoopFuture<[Word]> {
        guard let query = try? req.query.get(String.self, at: "query") else { throw Abort(.badRequest) }
        var queryBuilder = WordModel
            .query(on: req.db)
            .with(\.$synonyms) { synonyms in synonyms.with(\.$words) }
            .with(\.$antonyms)
            .range(..<100)
        
        let trimmedQuery = query.cleaned
        guard !trimmedQuery.isEmpty else { throw Abort(.noContent) }
        let splittedQuery = trimmedQuery.byWords
        if splittedQuery.count > 1 {
            var references = [trimmedQuery]
            references.append(contentsOf: splittedQuery)
            return queryBuilder
                .filter(\.$original ~~ references)
                .all()
                .map { $0.map { $0.output } }
                .map { words in
                    words.sorted { splittedQuery.firstIndex(of: $0.original) ?? 0 < splittedQuery.firstIndex(of: $1.original) ?? 0  }
                }
        } else {
            queryBuilder = queryBuilder
                .group(.or) {
                    $0
                        .filter(\.$original =~ trimmedQuery)
                        .filter(\.$original ~= trimmedQuery)
                }
        }
        
        return queryBuilder
            .all()
            .map { words in
                words.map { $0.output }
            }
    }
}
