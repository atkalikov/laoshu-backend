import Fluent

struct CreateSynonym: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(SynonymModel.schema)
            .field(.id, .string, .identifier(auto: false))
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(SynonymModel.schema).delete()
    }
}
