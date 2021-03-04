import Vapor
import Fluent
import LaoshuCore

final class ExampleController: RouteCollection {

    func boot(routes: RoutesBuilder) throws {
        let converterBuilder = routes.grouped("example")
        converterBuilder.get(use: get(req:))
    }
    
    func get(req: Request) throws -> EventLoopFuture<[Example]> {
        guard let target = try? req.query.get(String.self, at: "target") else { throw Abort(.badRequest) }
        
        let targetQuery = target.cleaned
        guard !targetQuery.isEmpty else { throw Abort(.noContent) }
        
        return ExampleModel
            .query(on: req.db)
            .range(..<100)
            .group(.or) {
                $0
                    .filter(\.$original ~~ targetQuery)
                    .filter(\.$example ~~ targetQuery)
            }
            .all()
            .map { $0.map { $0.output } }
    }
}
