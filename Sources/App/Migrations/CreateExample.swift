import Fluent

struct CreateExample: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(ExampleModel.schema)
            .field(.id, .string, .identifier(auto: false))
            .field(FieldKey.Word.original, .string, .required)
            .field(FieldKey.Example.example, .string, .required)
            .unique(on: FieldKey.Word.original)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(ExampleModel.schema).delete()
    }
}
