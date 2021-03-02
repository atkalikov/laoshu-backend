import Fluent

struct CreateWord: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(WordModel.schema)
            .field(.id, .string, .identifier(auto: false))
            .field(FieldKey.Word.original, .string, .required)
            .unique(on: FieldKey.Word.original)
            .field(FieldKey.Word.transcription, .string)
            .field(FieldKey.Word.description, .string, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(WordModel.schema).delete()
    }
}
