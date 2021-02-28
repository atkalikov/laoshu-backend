import Fluent
import FluentMySQLDriver
import QueuesFluentDriver
import Vapor

public func configure(_ app: Application) throws {
    app.migrations.add(CreateWord())
    app.migrations.add(JobModelMigrate())
    
    app.databases.use(
        .mysql(
            hostname: "localhost",
            port: 3307,
            username: "vapor",
            password: "vapor",
            database: "vapor",
            tlsConfiguration: .forClient(certificateVerification: .none),
            connectionPoolTimeout: .hours(2)
        ), as: .mysql)
    app.queues.use(.fluent())
    
    let dictionaryParsingService = DictionaryParsingServiceImpl()
    app.queues.add(ParsingJob(service: dictionaryParsingService))
    
    try app.autoMigrate().wait()
    try app.queues.startInProcessJobs(on: .default)
    
    try routes(app)
}
