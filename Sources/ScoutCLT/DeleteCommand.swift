import ArgumentParser
import Scout
import Foundation

struct DeleteCommand: ParsableCommand {

    // MARK: - Constants

    static let configuration = CommandConfiguration(commandName: "delete", abstract: "Delete a value at a given path")

    // MARK: - Properties

    @Argument()
    var readingPath: Path

    @Option(name: [.short, .customLong("--input")], help: "A file path from which to read the data")
    var inputFilePath: String?

    @Option(name: [.short, .long], help: "Write the modified data into the file at the given path")
    var output: String?

    @Flag(name: [.short, .long], default: false, inversion: .prefixedNo, help: "Output the modified data")
    var verbose: Bool

    // MARK: - Functions

    func run() throws {

        if let filePath = inputFilePath {
            let data = try Data(contentsOf: URL(fileURLWithPath: filePath.replacingTilde))
            try delete(from: data)
        } else {
            let streamInput = FileHandle.standardInput.readDataToEndOfFile()
            try delete(from: streamInput)
        }
    }

    func delete(from data: Data) throws {

        if var json = try? PathExplorerFactory.make(Json.self, from: data) {
            try json.delete(readingPath)
            try ScoutCommand.output(output, dataWith: json, verbose: verbose)

        } else if var plist = try? PathExplorerFactory.make(Plist.self, from: data) {
            try plist.delete(readingPath)
            try ScoutCommand.output(output, dataWith: plist, verbose: verbose)

        } else if var xml = try? PathExplorerFactory.make(Xml.self, from: data) {
            try xml.delete(readingPath)
            try ScoutCommand.output(output, dataWith: xml, verbose: verbose)

        } else {
            if let filePath = inputFilePath {
                throw RuntimeError.unknownFormat("The format of the file at \(filePath) is not recognized")
            } else {
                throw RuntimeError.unknownFormat("The format of the input stream is not recognized")
            }
        }
    }
}
