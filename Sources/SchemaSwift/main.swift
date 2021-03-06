import ArgumentParser
import SwiftgreSQL
import SchemaSwiftLibrary

struct SchemaSwift: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "A utility for generating Swift row structs from a Postgres schema.",
        version: "1.0.0",
        subcommands: [Generate.self],
        defaultSubcommand: Generate.self
    )
}

struct Generate: ParsableCommand {
    @Option(help: "The full url for the Postgres server, with username, password, database name, and port.")
    var url: String

    func run() throws {
        let database = try Database(url: url)
        let tables = try database.fetchTableNames().map({ try database.fetchTableDefinition(tableName: $0) })

        var string = ""
        for table in tables {
            string += """
            struct \(Inflections.upperCamelCase(Inflections.singularize(table.name))) {
                static let name = "\(table.name)"


            """

            for column in table.columns {
                string += """
                    let \(Inflections.lowerCamelCase(column.name)): \(column.swiftType)\(column.isNullable ? "?" : "")

                """
            }


            string += """
            }


            """
        }
        print(string)
    }
}

SchemaSwift.main()
