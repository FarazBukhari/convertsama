import Foundation

// convertsama-cli — headless harness over the same engines the app uses.
// See `convertsama-cli help`.
let status = await CLI.run(Array(CommandLine.arguments.dropFirst()))
exit(status)
