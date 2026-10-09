// =============================================================
//  Station ALMA-7, Part III: The Repair Fleet
//  iOS Mobile Development · Module 5 · Lab Assignment
//
//  How to use:
//   • Xcode: File → New → Playground → Blank, replace everything
//     with this file's contents.
//   • Terminal: swift ALMA7_Part3_Starter.swift
//
//  Rules:
//   • Do NOT modify the STARTER DATA section. LegacyBeacon in
//     particular must be reached with an extension, not edited.
//   • `!` (force unwrap) is forbidden: −0.5 points each.
//   • No map / filter / reduce / compactMap.
//   • The Health Rule must exist in exactly ONE place in this file.
// =============================================================


// MARK: - =================== STARTER DATA ===================
// MARK: - Do not modify anything in this section

/// Drone records recovered from the fleet registry.
/// One `kind` does not correspond to any drone type you will build.
let fleetData: [(kind: String, id: String, charge: Int)] = [
    (kind: "welder",  id: "W-1", charge: 80),
    (kind: "scanner", id: "S-1", charge: 45),
    (kind: "cargo",   id: "C-1", charge: 100),
    (kind: "welder",  id: "W-2", charge: 15),
    (kind: "scanner", id: "S-2", charge: 60),
    (kind: "tug",     id: "T-1", charge: 50)
]

/// Hull sensors. These are NOT drones — they never move and never work a shift.
let sensorData: [(id: String, charge: Int)] = [
    (id: "hull-cam", charge: 12),
    (id: "thermal",  charge: 77)
]

/// Hardware from the original station. You may not add anything to this
/// declaration — no methods, no protocols, no properties.
struct LegacyBeacon {
    let name: String
    let signalStrength: Int
}

let beacon = LegacyBeacon(name: "ALMA-BEACON", signalStrength: 8)

print("Fleet registry online: \(fleetData.count) drone records, \(sensorData.count) sensors, beacon \(beacon.name).")

// MARK: - ================= END OF STARTER DATA =================


// MARK: - =================== YOUR SOLUTION ===================

// MARK: Level 1 · The Power Cell

// Why a class and not a struct here? ->
// A class is needed here to provide shared reference semantics, allowing multiple drones or systems to share and modify the same underlying PowerCell instance without creating detached value copies.
final class PowerCell {
    private var charge: Int

    init(charge: Int) {
        self.charge = Swift.max(0, Swift.min(100, charge))
    }

    func level() -> Int {
        return charge
    }

    func spend(amount: Int) -> Bool {
        guard amount > 0, charge >= amount else { return false }
        charge -= amount
        return true
    }

    func recharge(by amount: Int) {
        guard amount > 0 else { return }
        charge = Swift.min(100, charge + amount)
    }
}

// Encapsulation proof:
// let cell = PowerCell(charge: 100)
// cell.charge = 100
// error: 'charge' is inaccessible due to 'private' protection level


// MARK: Level 2 · The Fleet

// 2.1
// What does `final` on runOnce() buy you? ->
// `final` prevents subclasses from overriding `runOnce()`, ensuring that the core shift execution flow and power check ritual cannot be altered or bypassed by individual drone types.
class Drone {
    let id: String
    let cell: PowerCell

    init(id: String, cell: PowerCell) {
        self.id = id
        self.cell = cell
    }

    var powerCost: Int { 10 }

    var statusLine: String {
        return "\(id): \(cell.level().powerBar)"
    }

    func performTask() -> Int {
        return 0
    }

    final func runOnce() -> Int {
        guard cell.spend(amount: powerCost) else { return 0 }
        return performTask()
    }
}

// 2.2
class WelderDrone: Drone {
    override var powerCost: Int { 25 }

    override func performTask() -> Int {
        return 40
    }

    func weldSeam() -> String {
        return "Seam welded by \(id)"
    }
}

class ScannerDrone: Drone {
    override var powerCost: Int { 10 }

    override func performTask() -> Int {
        return 15
    }

    override var statusLine: String {
        return super.statusLine + " [scanner]"
    }
}

final class CargoDrone: Drone {
    override var powerCost: Int { 20 }

    override func performTask() -> Int {
        return 25
    }
}

// 2.3
func makeDrone(kind: String, id: String, charge: Int) -> Drone? {
    let cell = PowerCell(charge: charge)
    switch kind {
    case "welder":
        return WelderDrone(id: id, cell: cell)
    case "scanner":
        return ScannerDrone(id: id, cell: cell)
    case "cargo":
        return CargoDrone(id: id, cell: cell)
    default:
        return nil
    }
}

var fleet: [Drone] = []
print("--- Level 2.3: Fleet Assembly ---")
for record in fleetData {
    if let drone = makeDrone(kind: record.kind, id: record.id, charge: record.charge) {
        fleet.append(drone)
    } else {
        print("Warning: Unknown drone kind '\(record.kind)' for ID '\(record.id)'. Record skipped.")
    }
}


// MARK: Level 3 · The Shift

func runShift(_ fleet: [Drone], rounds: Int) -> Int {
    var totalWork = 0
    for _ in 0..<rounds {
        for drone in fleet {
            totalWork += drone.runOnce()
        }
    }
    return totalWork
}

print("\n--- Level 3: Running Shift ---")
let A = runShift(fleet, rounds: 3)

var totalChargeAfterShift = 0
var readyDroneCount = 0

print("Fleet status after shift:")
for drone in fleet {
    print(drone.statusLine)
    let currentCharge = drone.cell.level()
    totalChargeAfterShift += currentCharge
    if currentCharge >= drone.powerCost {
        readyDroneCount += 1
    }
}

let B = totalChargeAfterShift
let C = readyDroneCount

print("Fragment A (Total Work): \(A)")
print("Fragment B (Total Remaining Charge): \(B)")
print("Fragment C (Ready Drones Count): \(C)")


// MARK: Level 4 · Diagnostics

// 4.1
protocol Diagnosable {
    var componentID: String { get }
    var statusCode: Int { get }
    func diagnose() -> String
}

// 4.2
protocol Rechargeable {
    mutating func recharge(by amount: Int)
}

// Why does Drone implement recharge(by:) without `mutating`? ->
// `Drone` is a class (reference type). Classes inherently operate with shared reference semantics and can mutate their internal state without changing their reference identity, so they don't use the `mutating` keyword.
extension Drone: Diagnosable, Rechargeable {
    var componentID: String { id }

    var statusCode: Int {
        return statusCode(forCharge: cell.level())
    }

    func recharge(by amount: Int) {
        cell.recharge(by: amount)
    }
}

struct SensorModule: Diagnosable, Rechargeable {
    let id: String
    var chargeLevel: Int

    var componentID: String { id }

    var statusCode: Int {
        return statusCode(forCharge: chargeLevel)
    }

    mutating func recharge(by amount: Int) {
        guard amount > 0 else { return }
        chargeLevel = Swift.min(100, chargeLevel + amount)
    }
}

// 4.3
// Why could [Drone] never have held the sensors? ->
// `[Drone]` is a concrete class array that can only hold instances of `Drone` or its subclasses; `SensorModule` is a `struct` completely outside the `Drone` inheritance tree.
func diagnosticsReport(_ components: [Diagnosable]) -> String {
    var report = "--- DIAGNOSTICS REPORT ---"
    for component in components {
        report += "\n" + component.diagnose()
    }
    return report
}


// MARK: Level 5 · Shared Behaviour

// 5.1 · Default diagnose() + the SINGLE home of the Health Rule
extension Diagnosable {
    func diagnose() -> String {
        return "\(componentID): code \(statusCode)"
    }

    /// The Health Rule: implemented in EXACTLY ONE place across the entire system.
    func statusCode(forCharge value: Int) -> Int {
        if value < 20 {
            return 2 // critical
        } else if value < 50 {
            return 1 // warning
        } else {
            return 0 // nominal
        }
    }
}

// 5.2 · The legacy beacon you cannot edit
extension LegacyBeacon: Diagnosable {
    var componentID: String { name }

    var statusCode: Int {
        return statusCode(forCharge: signalStrength)
    }

    func diagnose() -> String {
        return "[LEGACY HARDWARE] \(componentID): code \(statusCode) (signal: \(signalStrength))"
    }
}

print("\n--- Level 4 & 5: Diagnostics System ---")

var diagnosticComponents: [Diagnosable] = []

for drone in fleet {
    diagnosticComponents.append(drone)
}

for sensor in sensorData {
    diagnosticComponents.append(SensorModule(id: sensor.id, chargeLevel: sensor.charge))
}

diagnosticComponents.append(beacon)

print(diagnosticsReport(diagnosticComponents))

var sumOfStatusCodes = 0
for component in diagnosticComponents {
    sumOfStatusCodes += component.statusCode
}

let D = sumOfStatusCodes
print("Fragment D (Sum of Status Codes): \(D)")

// 5.3
extension Int {
    var powerBar: String {
        let clamped = Swift.max(0, Swift.min(100, self))
        let hashCount = clamped / 10
        let dotCount = 10 - hashCount
        
        var bar = ""
        for _ in 0..<hashCount { bar += "#" }
        for _ in 0..<dotCount { bar += "." }
        return bar
    }
}


// MARK: Level 6 · Incident Reports

print("\n--- Level 6: Incident Reports Fixes ---")

// Report 1
// Expectation: Overriding `performTask()` to return 30 work units.
// Actual: Fails to compile because it lacks the required `override` keyword.
// Language Rule: Overriding inherited class methods requires an explicit `override` keyword in Swift.
// Fix:
class PatchDrone: Drone {
    override func performTask() -> Int {
        return 30
    }
}
let patcher = PatchDrone(id: "P-1", cell: PowerCell(charge: 100))
print("Report 1 Fixed Task Output: \(patcher.performTask())")

// Report 2
// Expectation: Override `runOnce()` to return custom work units.
// Actual: Fails to compile because `runOnce()` was declared as `final` in `Drone`.
// Language Rule: Methods marked as `final` cannot be overridden by subclasses.
// Fix: Overriding `performTask()` instead of `runOnce()`.
final class HeavyWelder: WelderDrone {
    override func performTask() -> Int {
        return 999
    }
}
let heavy = HeavyWelder(id: "HW-1", cell: PowerCell(charge: 100))
print("Report 2 Fixed Output via performTask: \(heavy.performTask())")

// Report 3
// Expectation: Call subclass method `weldSeam()` on an element from `[Drone]`.
// Actual: Does not compile because `reportFleet` has static type `[Drone]`, which doesn't define `weldSeam()`.
// Language Rule: Call availability is checked against the static type. Conditional downcasting (`as?`) is required to safely cast to a subclass at runtime.
// Fix:
let reportFleet: [Drone] = [WelderDrone(id: "W-9", cell: PowerCell(charge: 100))]
let first = reportFleet[0]
if let welder = first as? WelderDrone {
    print("Report 3 Fixed: \(welder.weldSeam())")
}

// Report 4
// Expectation: Prints "thruster T-1" when calling `label()` on a `Labelled` protocol variable containing `Thruster`.
// Actual: Prints "generic component" because static dispatch picked the protocol extension method instead of the struct method.
// Language Rule: When a method is defined in a protocol extension but NOT declared in the protocol interface itself, it uses static dispatch based on the variable's existential type (`Labelled`), ignoring the dynamic type's implementation.
// Fix: Declare `func label() -> String` inside the `Labelled` protocol definition to enable dynamic dispatch.
protocol Labelled {
    var componentID: String { get }
    func label() -> String
}

extension Labelled {
    func label() -> String { "generic component" }
}

struct Thruster: Labelled {
    let componentID: String
    func label() -> String { "thruster \(componentID)" }
}

let parts: [Labelled] = [Thruster(componentID: "T-1")]
print("Report 4 Fixed: \(parts[0].label())")


// MARK: Finale · Mission Code

print("\n--- Finale: Mission Code ---")
let missionCode = "\(A)-\(B)-\(C)-\(D)"
print("MISSION CODE: \(missionCode)")


// MARK: Bonus

/*
 1. Two ways to forbid using Drone directly:
 - Runtime: Add `fatalError("Drone is an abstract base class and cannot be instantiated directly")` inside `Drone.init` or `performTask()`.
 - Compile-time: Replace `Drone` with a protocol (or make `init` private/unavailable), forcing callers to instantiate concrete conforming types like `WelderDrone`.

 2 & 3. Protocol-based redesign comparison:
 The class hierarchy design is better suited for this station because power cells represent shared, stateful physical hardware that needs reference semantics. If drones were structs, mutating internal state across multiple subsystems would lead to accidental value copies rather than shared state updates.
*/


// MARK: - ================= DEFENSE QUESTIONS =================
/*
 1. Why does a class satisfy a `mutating` protocol requirement without the keyword, while a struct must write it?
    Classes are reference types, so modifying internal properties does not change the instance reference itself.
    Structs are value types, where modifying any property changes the underlying value, requiring explicit `mutating` annotation to grant permission for value modification.

 2. One thing inheritance does that protocols cannot, and one thing protocols do that inheritance cannot:
    Inheritance enables sharing stored property declarations and implementation logic directly through a single base class hierarchy.
    Protocols enable defining shared behavior across completely unrelated types (structs, classes, enums, or retroactive extensions on legacy/built-in types) without forcing them into a rigid single-inheritance hierarchy.

 3. What does `final` prevent, and what did it protect in runOnce()?
    `final` prevents subclasses from overriding a method, property, or inheriting from a class.
    Making `runOnce()` final ensures that subclasses cannot override the shift execution ritual or bypass the charge checks, enforcing uniform execution rules across all drones.

 4. In Report 4, why did the protocol extension's method win?
    Because `func label() -> String` was missing from the main protocol declaration.
    When a function is only defined inside a protocol extension, Swift uses static dispatch based on the existential variable's static type (`Labelled`), ignoring the dynamic type's (`Thruster`) custom method.
*/