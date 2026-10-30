import AppKit

@main
@MainActor
enum ConvertSamaMain {
    static func main() {
        migrateLegacyDefaults()
        let app = NSApplication.shared
        let delegate = AppDelegate()   // NSApplication.delegate is weak; run() keeps this frame alive
        app.delegate = delegate
        app.setActivationPolicy(.accessory)
        app.run()
    }

    /// One-time copy of preferences saved under the pre-rename bundle id (Rondo), before
    /// AppDelegate loads Settings and RecentOutputs. The app isn't sandboxed, so the old domain
    /// is readable. Keys already set here win.
    private static func migrateLegacyDefaults() {
        let defaults = UserDefaults.standard
        let doneKey = "legacyDefaultsMigrated.v1"
        guard !defaults.bool(forKey: doneKey) else { return }
        defaults.set(true, forKey: doneKey)
        guard let legacy = defaults.persistentDomain(forName: "com.farazbukhari.rondo") else { return }
        for (key, value) in legacy where defaults.object(forKey: key) == nil {
            defaults.set(value, forKey: key)
        }
    }
}
