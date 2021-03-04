import Fluent

struct CreateExample: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(ExampleModel.schema)
            .field(.id, .string, .identifier(auto: false))
            .field(FieldKey.Example.original, .sql(raw: "TEXT"), .required)
            .field(FieldKey.Example.example, .sql(raw: "TEXT"), .required)
            .constraint(.custom("INDEX example_index (original(40), example(40))"))
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(ExampleModel.schema).delete()
    }
}
