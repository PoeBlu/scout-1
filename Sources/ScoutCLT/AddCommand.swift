import ArgumentParser
import Scout
import Foundation

private let discussion =
"""
Notes: All the keys which do not exist in the path will be created.
=====

Given the following Json (as input stream or file)

{
  "people": {
    "Tom": {
      "height": 175,
      "age": 68,
      "hobbies": [
        "cooking",
        "guitar"
      ]
    },
    "Arnaud": {
      "height": 180,
      "age": 23,
      "hobbies": [
        "video games",
        "party",
        "tennis"
      ]
    }
  }
}

Examples
================

`scout add "people->Franklin->height":165` will create a new dictionary Franklin and add a height key into it with the value 165
`scout add "people->Tom->hobbies->[-1]:"Playing music"` will add the hobby "Playing music" to Tom hobbies at the end of the array
`scout add "people->Arnaud->hobbies->[1]:reading` will insert the hobby "reading" to Arnaud hobbies between the hobby "video games" and "party"
`scout add "people->Franklin->hobbies->[0]":"football"` will create a new dictionary Franklin, add a hobbies array into it, and insert the value "football" in the array
"""

struct AddCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "add",
        abstract: "Add value at a given path")

    @Argument(help: PathAndValue.help)
    var pathsAndValues: [PathAndValue]

    @Option(name: [.short, .customLong("--input")], help: "A file path from which to read the data")
    var inputFilePath: String?

    @Option(name: [.short, .long], help: "Write the modified data into the file at the given path")
    var output: String?

    @Flag(name: [.short, .long], default: false, inversion: .prefixedNo, help: "Output the modified data")
    var verbose: Bool
    
    func run() throws {

        if let filePath = inputFilePath {
            let data = try Data(contentsOf: URL(fileURLWithPath: filePath.replacingTilde))
            try add(from: data)
        } else {
            let streamInput = FileHandle.standardInput.readDataToEndOfFile()
            try add(from: streamInput)
        }
    }

    func add(from data: Data) throws {

        if var json = try? PathExplorerFactory.make(Json.self, from: data) {
            try pathsAndValues.forEach { try json.add($0.value, at: $0.readingPath) }
            try ScoutCommand.output(output, dataWith: json, verbose: verbose)

        } else if var plist = try? PathExplorerFactory.make(Plist.self, from: data) {
            try pathsAndValues.forEach { try plist.add($0.value, at: $0.readingPath) }
            try ScoutCommand.output(output, dataWith: plist, verbose: verbose)

        } else if var xml = try? PathExplorerFactory.make(Xml.self, from: data) {
            try pathsAndValues.forEach { try xml.add($0.value, at: $0.readingPath) }
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
