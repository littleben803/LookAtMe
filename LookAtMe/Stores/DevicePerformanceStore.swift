import Combine
import Foundation
import UIKit

struct DevicePerformanceProfile: Equatable {
    let identifier: String
    let score: Int
    let tier: DevicePerformanceTier
    let componentScores: DevicePerformanceComponentScores
    let physicalMemoryGB: Double
    let activeProcessorCount: Int
    let isLowPowerModeEnabled: Bool
    let thermalState: ProcessInfo.ThermalState
    let hasRecentMemoryPressure: Bool

    var enablesHomeFireworks: Bool {
        score >= DevicePerformanceScorer.homeFireworksMinimumScore
    }
}

enum DevicePerformanceTier: String, Equatable {
    case limited
    case balanced
    case high
}

struct DevicePerformanceComponentScores: Equatable {
    let memory: Int
    let processor: Int
    let generation: Int
    let runtime: Int
    let memoryPressure: Int
}

enum DevicePerformanceScorer {
    static let homeFireworksMinimumScore = 78
    static let recentMemoryPressurePenalty = 30

    static func currentProfile(
        processInfo: ProcessInfo = .processInfo,
        hasRecentMemoryPressure: Bool = false
    ) -> DevicePerformanceProfile {
        let identifier = deviceIdentifier(processInfo: processInfo)
        let memoryGB = Double(processInfo.physicalMemory) / 1_073_741_824
        let componentScores = DevicePerformanceComponentScores(
            memory: memoryScore(memoryGB: memoryGB),
            processor: processorScore(activeProcessorCount: processInfo.activeProcessorCount),
            generation: generationScore(identifier: identifier),
            runtime: runtimeScore(processInfo: processInfo),
            memoryPressure: memoryPressureScore(hasRecentMemoryPressure: hasRecentMemoryPressure)
        )
        let score = max(
            0,
            min(
                100,
                componentScores.memory +
                    componentScores.processor +
                    componentScores.generation +
                    componentScores.runtime +
                    componentScores.memoryPressure
            )
        )

        return DevicePerformanceProfile(
            identifier: identifier,
            score: score,
            tier: tier(for: score),
            componentScores: componentScores,
            physicalMemoryGB: memoryGB,
            activeProcessorCount: processInfo.activeProcessorCount,
            isLowPowerModeEnabled: processInfo.isLowPowerModeEnabled,
            thermalState: processInfo.thermalState,
            hasRecentMemoryPressure: hasRecentMemoryPressure
        )
    }

    private static func memoryScore(memoryGB: Double) -> Int {
        switch memoryGB {
        case 8...:
            40
        case 6..<8:
            34
        case 4..<6:
            24
        case 3..<4:
            14
        default:
            6
        }
    }

    private static func processorScore(activeProcessorCount: Int) -> Int {
        switch activeProcessorCount {
        case 8...:
            20
        case 6..<8:
            16
        case 4..<6:
            10
        default:
            6
        }
    }

    private static func generationScore(identifier: String) -> Int {
        guard let model = parsedModelIdentifier(identifier) else {
            return identifier.hasPrefix("Mac") ? 35 : 14
        }

        switch model.family {
        case "iPhone":
            return iPhoneGenerationScore(major: model.major)
        case "iPad":
            return iPadGenerationScore(major: model.major)
        case "Mac":
            return 35
        default:
            return 14
        }
    }

    private static func runtimeScore(processInfo: ProcessInfo) -> Int {
        let thermalScore: Int
        switch processInfo.thermalState {
        case .nominal:
            thermalScore = 5
        case .fair:
            thermalScore = 2
        case .serious:
            thermalScore = -12
        case .critical:
            thermalScore = -25
        @unknown default:
            thermalScore = 0
        }

        return thermalScore - (processInfo.isLowPowerModeEnabled ? 8 : 0)
    }

    private static func memoryPressureScore(hasRecentMemoryPressure: Bool) -> Int {
        hasRecentMemoryPressure ? -recentMemoryPressurePenalty : 0
    }

    private static func iPhoneGenerationScore(major: Int) -> Int {
        switch major {
        case 16...:
            35
        case 15:
            30
        case 14:
            24
        case 13:
            18
        case 12:
            12
        default:
            6
        }
    }

    private static func iPadGenerationScore(major: Int) -> Int {
        switch major {
        case 14...:
            35
        case 13:
            30
        case 12:
            24
        case 11:
            18
        default:
            10
        }
    }

    private static func tier(for score: Int) -> DevicePerformanceTier {
        switch score {
        case homeFireworksMinimumScore...:
            .high
        case 55..<homeFireworksMinimumScore:
            .balanced
        default:
            .limited
        }
    }

    private static func deviceIdentifier(processInfo: ProcessInfo) -> String {
#if targetEnvironment(simulator)
        if let simulatedIdentifier = processInfo.environment["SIMULATOR_MODEL_IDENTIFIER"] {
            return simulatedIdentifier
        }
#endif

        var systemInfo = utsname()
        uname(&systemInfo)
        return Mirror(reflecting: systemInfo.machine).children.reduce(into: "") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else {
                return
            }
            identifier.append(Character(UnicodeScalar(UInt8(bitPattern: value))))
        }
    }

    private static func parsedModelIdentifier(_ identifier: String) -> (family: String, major: Int)? {
        let family = String(identifier.prefix { $0.isLetter })
        let version = identifier.dropFirst(family.count)
        let parts = version.split(separator: ",")
        guard let firstPart = parts.first, let major = Int(firstPart) else {
            return nil
        }
        return (family, major)
    }
}

@MainActor
final class DevicePerformanceStore: ObservableObject {
    @Published private(set) var profile: DevicePerformanceProfile

    private static let memoryPressureCooldown: TimeInterval = 5 * 60

    private let processInfo: ProcessInfo
    private var cancellables: Set<AnyCancellable> = []
    private var memoryPressureExpiresAt: Date?
    private var memoryPressureClearTask: Task<Void, Never>?

    init(processInfo: ProcessInfo = .processInfo) {
        self.processInfo = processInfo
        self.profile = DevicePerformanceScorer.currentProfile(processInfo: processInfo)

        NotificationCenter.default.publisher(for: ProcessInfo.thermalStateDidChangeNotification)
            .sink { [weak self] _ in
                Task { @MainActor in
                    self?.refresh()
                }
            }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: Notification.Name.NSProcessInfoPowerStateDidChange)
            .sink { [weak self] _ in
                Task { @MainActor in
                    self?.refresh()
                }
            }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: UIApplication.didReceiveMemoryWarningNotification)
            .sink { [weak self] _ in
                Task { @MainActor in
                    self?.recordMemoryPressure()
                }
            }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
            .sink { [weak self] _ in
                Task { @MainActor in
                    self?.refresh()
                }
            }
            .store(in: &cancellables)
    }

    func refresh() {
        profile = DevicePerformanceScorer.currentProfile(
            processInfo: processInfo,
            hasRecentMemoryPressure: isMemoryPressureActive()
        )
    }

    private func recordMemoryPressure() {
        memoryPressureExpiresAt = Date().addingTimeInterval(Self.memoryPressureCooldown)
        refresh()
        scheduleMemoryPressureClear()
    }

    private func isMemoryPressureActive(now: Date = Date()) -> Bool {
        guard let memoryPressureExpiresAt else {
            return false
        }

        if now < memoryPressureExpiresAt {
            return true
        }

        self.memoryPressureExpiresAt = nil
        return false
    }

    private func scheduleMemoryPressureClear() {
        memoryPressureClearTask?.cancel()

        guard let memoryPressureExpiresAt else {
            return
        }

        let remainingSeconds = max(0, memoryPressureExpiresAt.timeIntervalSinceNow)
        memoryPressureClearTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: UInt64(remainingSeconds * 1_000_000_000))
            await MainActor.run {
                self?.refresh()
            }
        }
    }
}
