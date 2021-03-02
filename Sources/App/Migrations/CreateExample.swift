import Fluent

struct CreateExample: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(ExampleModel.schema)
            .field(FieldKey.Example.original, .string, .identifier(auto: false))
            .field(FieldKey.Example.example, .string, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(ExampleModel.schema).delete()
    }
}
