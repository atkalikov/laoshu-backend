import Fluent

struct CreateExample: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(ExampleModel.schema)
            .id()
            .field("original", .string, .required)
            .field("example", .string, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(ExampleModel.schema).delete()
    }
}
