// swift-tools-version:6.0
// ConvertSama — clean-room macOS menu-bar file converter. See docs/ARCHITECTURE.md.
import PackageDescription

let kit: Target.Dependency = "ConvertSamaKit"

let package = Package(
    name: "ConvertSama",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "ConvertSama", targets: ["ConvertSama"]),
        .executable(name: "convertsama-cli", targets: ["ConvertSamaCLI"]),
    ],
    targets: [
        // Contracts + support (orchestrator-owned)
        .target(name: "ConvertSamaKit"),

        // Engines
        .target(name: "ImageEngine", dependencies: [kit]),
        .target(name: "PDFEngine", dependencies: [kit]),
        .target(name: "MediaEngine", dependencies: [kit]),
        .target(name: "DocEngine", dependencies: [kit]),

        // UI modules
        .target(name: "ConvertSamaInteraction", dependencies: [kit]),
        .target(name: "ConvertSamaShell", dependencies: [kit]),
        .target(name: "ImageEditorUI", dependencies: [kit, "ImageEngine"]),
        .target(name: "MediaEditorUI", dependencies: [kit, "MediaEngine"]),
        .target(name: "PDFOrganizerUI", dependencies: [kit, "PDFEngine"]),

        // Executables (orchestrator-owned)
        .executableTarget(
            name: "ConvertSama",
            dependencies: [
                kit, "ImageEngine", "PDFEngine", "MediaEngine", "DocEngine",
                "ConvertSamaInteraction", "ConvertSamaShell",
                "ImageEditorUI", "MediaEditorUI", "PDFOrganizerUI",
            ]
        ),
        .executableTarget(
            name: "ConvertSamaCLI",
            dependencies: [kit, "ImageEngine", "PDFEngine", "MediaEngine", "DocEngine"],
            path: "Sources/convertsama-cli"
        ),

        // Tests — run via scripts/test.sh (Swift Testing needs CLT framework flags)
        .testTarget(name: "ConvertSamaKitTests", dependencies: [kit]),
        .testTarget(name: "ImageEngineTests", dependencies: [kit, "ImageEngine"]),
        .testTarget(name: "PDFEngineTests", dependencies: [kit, "PDFEngine"]),
        .testTarget(name: "MediaEngineTests", dependencies: [kit, "MediaEngine"]),
        .testTarget(name: "DocEngineTests", dependencies: [kit, "DocEngine"]),
        .testTarget(name: "ConvertSamaInteractionTests", dependencies: [kit, "ConvertSamaInteraction"]),
        .testTarget(name: "ConvertSamaShellTests", dependencies: [kit, "ConvertSamaShell"]),
        .testTarget(name: "ImageEditorUITests", dependencies: [kit, "ImageEditorUI", "ImageEngine"]),
        .testTarget(name: "MediaEditorUITests", dependencies: [kit, "MediaEditorUI", "MediaEngine"]),
        .testTarget(name: "PDFOrganizerUITests", dependencies: [kit, "PDFOrganizerUI", "PDFEngine"]),
    ],
    swiftLanguageModes: [.v5]
)
