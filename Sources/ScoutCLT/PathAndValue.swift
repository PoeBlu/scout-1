import ArgumentParser
import Scout

private let abstract =
"""
Let you specify a reading path with an associated value.
Like this: `FirstKey->SecondKey->[FirstIndex]->ThirdKey":value` or `"FirstKey->[FirstIndex]":"Text value with spaces"`
"""

/// Represent a reading path and an associated value, like `path->components->[0]:value`.
/// Putting the value between sharp signs `#value#` indicates a key name modification
struct PathAndValue: ExpressibleByArgument {

    // MARK: - Constants

    static let help = ArgumentHelp(abstract, valueName: "path:value", shouldDisplay: true)

    // MARK: - Properties

    let readingPath: Path
    let value: String

    /// Set to `true` when the value is a key name to change. A key name will be indicated with sharps #KeyName#
    let changeKey: Bool

    init?(argument: String) {
        let splitted = argument.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: true)
        guard
            splitted.count == 2,
            let readingPath = Path(argument: String(splitted[0]))
        else {
            return nil
        }

        self.readingPath = readingPath

        var value = String(splitted[1])
        if value.hasPrefix("#"), value.hasSuffix("#") {
            value.removeFirst()
            value.removeLast()
            self.value = value
            changeKey = true
        } else {
            self.value = value
            changeKey = false
        }
    }
}
