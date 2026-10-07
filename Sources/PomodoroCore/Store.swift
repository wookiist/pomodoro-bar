import Foundation

private struct StoreFile: Decodable {
    let plan: Plan?
}

public enum Store {
    public static var defaultDirectory: URL {
        let base = ProcessInfo.processInfo.environment["CLAUDE_CONFIG_DIR"].map { URL(fileURLWithPath: $0) }
            ?? FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".claude")
        return base.appendingPathComponent("plugins/store")
    }

    public static func latestPlan(in directory: URL = defaultDirectory) -> Plan? {
        let files = (try? FileManager.default.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: [.contentModificationDateKey]
        )) ?? []
        let newest = files
            .filter { $0.lastPathComponent.hasPrefix("pomodoro_") && $0.pathExtension == "json" }
            .max { modified($0) < modified($1) }
        guard let newest, let data = try? Data(contentsOf: newest) else { return nil }
        return (try? JSONDecoder().decode(StoreFile.self, from: data))?.plan.flatMap(valid)
    }

    private static func modified(_ url: URL) -> Date {
        (try? url.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? .distantPast
    }

    private static func valid(_ plan: Plan) -> Plan? {
        plan.focusMin > 0 && plan.breakMin > 0 ? plan : nil
    }
}
