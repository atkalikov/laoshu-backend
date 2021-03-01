import Fluent
import FluentMySQLDriver
import QueuesFluentDriver
import Vapor

public func configure(_ app: Application) throws {
    app.migrations.add(CreateWord())
    app.migrations.add(CreateExample())
    app.migrations.add(JobModelMigrate())
    
    app.databases.use(
        .mysql(
            hostname: Environment.get("DATABASE_HOST") ?? "localhost",
            port: 3306,
            username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
            password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
            database: Environment.get("DATABASE_NAME") ?? "vapor_database",
            tlsConfiguration: .forClient(certificateVerification: .none),
            connectionPoolTimeout: .hours(2)
        ), as: .mysql)
    app.queues.use(.fluent())
    
    let job = ParsingJob(app.parsingService)
    app.queues.add(job)
    
    try app.autoMigrate().wait()
    try app.queues.startInProcessJobs(on: .default)
    
    try routes(app)
}
