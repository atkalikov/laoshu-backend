import Fluent

struct CreateWord: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(WordModel.schema)
            .id()
            .field("original", .string, .required)
            .field("transcription", .string)
            .field("description", .string)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(WordModel.schema).delete()
    }
}
