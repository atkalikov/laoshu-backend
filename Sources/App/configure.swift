import Fluent
import FluentMySQLDriver
import QueuesFluentDriver
import Vapor

public func configure(_ app: Application) throws {
//    app.logger.logLevel = .debug
    
    try database(app)
    try queues(app)
    try routes(app)
}

private func database(_ app: Application) throws {
    app.migrations.add(CreateWord())
    app.migrations.add(CreateExample())
    app.migrations.add(CreateWordSynonyms())
    app.migrations.add(CreateSynonym())
    app.migrations.add(CreateWordAntonyms())
    app.migrations.add(JobModelMigrate())

    app.databases.use(
        .mysql(
            hostname: Environment.get("DATABASE_HOST") ?? "localhost",
            port: 3306,
            username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
            password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
            database: Environment.get("DATABASE_NAME") ?? "vapor_database",
            tlsConfiguration: .forClient(certificateVerification: .none),
            connectionPoolTimeout: .hours(1)
        ), as: .mysql)

    try app.autoMigrate().wait()
}


private func queues(_ app: Application) throws {
    let job = ParsingJob(app.parsingService)
    app.queues.add(job)
    app.queues.configuration.refreshInterval = .minutes(1)
    app.queues.use(.fluent())
    try app.queues.startInProcessJobs()
    try app.queues.startScheduledJobs()
}
