import Fluent

struct CreateWord: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(WordModel.schema)
            .field("original", .string, .identifier(auto: false))
            .field("transcription", .string)
            .field("description", .string)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("todos").delete()
    }
}
