import Fluent

struct CreateWordSynonyms: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(WordSynonyms.schema)
            .field(.id, .string, .identifier(auto: false))
            .field(FieldKey.WordSynonyms.synonymId, .string, .required)
            .field(FieldKey.WordSynonyms.wordId, .string, .required)
            .unique(on: FieldKey.WordSynonyms.synonymId, FieldKey.WordSynonyms.wordId)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(WordSynonyms.schema).delete()
    }
}
