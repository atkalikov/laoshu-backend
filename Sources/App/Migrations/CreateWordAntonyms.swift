import Fluent

struct CreateWordAntonyms: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(WordAntonyms.schema)
            .field(.id, .string, .identifier(auto: false))
            .field(FieldKey.WordAntonyms.antonymId, .string, .required)
            .field(FieldKey.WordAntonyms.wordId, .string, .required)
            .unique(on: FieldKey.WordAntonyms.antonymId, FieldKey.WordAntonyms.wordId)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(WordAntonyms.schema).delete()
    }
}
