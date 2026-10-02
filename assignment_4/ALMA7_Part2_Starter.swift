// =============================================================
//  Station ALMA-7, Part II: The Teleporter Incident
//  iOS Mobile Development · Module 4 · Lab Assignment
//
//  How to use:
//   • Xcode: File → New → Playground → Blank, replace everything
//     with this file's contents.
//   • Terminal: swift ALMA7_Part2_Starter.swift
//
//  Rules:
//   • Do NOT modify the STARTER DATA section.
//   • `!` (force unwrap) is forbidden: −0.5 points each.
//   • No map / filter / reduce / compactMap.
//   • Default to struct. Use class only where the task says so.
// =============================================================


// MARK: - =================== STARTER DATA ===================
// MARK: - Do not modify anything in this section

/// Splits a line into fields.
/// fields("crate:101:120")            -> ["crate", "101", "120"]
/// fields("livestock:lab mice:12:2")  -> ["livestock", "lab mice", "12", "2"]
/// fields("junk")                     -> ["junk"]
func fields(_ line: String, separatedBy separator: Character = ":") -> [String] {
    var result: [String] = []
    var current = ""
    for character in line {
        if character == separator {
            result.append(current)
            current = ""
        } else {
            current.append(character)
        }
    }
    result.append(current)
    return result
}

/// Cargo manifest as recovered from the damaged recorder.
let rawManifest = [
    "crate:101:120",
    "container:KZ-ALM-7:340",
    "livestock:lab mice:12:2",
    "???-corrupted-line",
    "crate:102:75",
    "container:KZ-ALM-9:410",
    "livestock:ficus:3:5",
    "crate:103:260",
    "crate:104:abc",
    ""
]

/// Oxygen readings. One of these deck names is not a real deck.
let deckReadings: [(deck: String, oxygen: Int)] = [
    (deck: "bridge",     oxygen: 78),
    (deck: "lab",        oxygen: 64),
    (deck: "greenhouse", oxygen: 55),
    (deck: "cargo",      oxygen: 12),
    (deck: "medbay",     oxygen: 90),
    (deck: "engine",     oxygen: 41)
]

/// Crew records, straight from the personnel file.
let crewData: [(name: String, deck: String, oxygen: Int)] = [
    (name: "Timur",   deck: "engine", oxygen: 62),
    (name: "Dana",    deck: "lab",    oxygen: 48),
    (name: "Aigerim", deck: "bridge", oxygen: 91),
    (name: "Nurlan",  deck: "cargo",  oxygen: 17)
]

print("ALMA-7 recorder online: \(rawManifest.count) manifest lines, \(deckReadings.count) readings, \(crewData.count) crew records.")

// MARK: - ================= END OF STARTER DATA =================


// MARK: - =================== YOUR SOLUTION ===================
// Uncomment each declaration when you start working on it.


// MARK: Level 1 · The Deck Register

// MARK: - =================== YOUR SOLUTION ===================

// MARK: Level 1 · The Deck Register

// 1.1
enum Deck: String, CaseIterable {
    case bridge
    case lab
    case cargo
    case medbay
    case engine

    var evacuationPriority: Int {
        switch self {
        case .bridge: return 1
        case .medbay: return 2
        case .lab: return 3
        case .engine: return 4
        case .cargo: return 5
        }
    }
}

print("Level 1.1: Decks")
for deck in Deck.allCases {
    print("Deck: \(deck.rawValue), Evacuation Priority: \(deck.evacuationPriority)")
}

// 1.2
enum AlarmLevel: Int {
    case green = 0
    case yellow
    case orange
    case red

    static func level(forTotalMass mass: Int) -> AlarmLevel {
        let raw = mass / 500
        return AlarmLevel(rawValue: raw) ?? .red
    }
}

print("\nLevel 1.2: Alarm Levels")
print("Mass 0kg: \(AlarmLevel.level(forTotalMass: 0))")
print("Mass 940kg: \(AlarmLevel.level(forTotalMass: 940))")
print("Mass 4000kg: \(AlarmLevel.level(forTotalMass: 4000))")


// MARK: Level 2 · The Manifest

// 2.1
enum ManifestEntry {
    case crate(id: Int, massKg: Int)
    case container(code: String, massKg: Int)
    case livestock(species: String, count: Int, massPerUnitKg: Int)
    case unknown(raw: String)
}

// 2.2
func parseEntry(_ line: String) -> ManifestEntry {
    let parts = fields(line)
    guard !parts.isEmpty else { return .unknown(raw: line) }

    switch parts[0] {
    case "crate":
        if parts.count == 3, let id = Int(parts[1]), let mass = Int(parts[2]) {
            return .crate(id: id, massKg: mass)
        }
    case "container":
        if parts.count == 3, let mass = Int(parts[2]) {
            return .container(code: parts[1], massKg: mass)
        }
    case "livestock":
        if parts.count == 4, let count = Int(parts[2]), let unitmass = Int(parts[3]) {
            return .livestock(species: parts[1], count: count, massPerUnitKg: unitmass)
        }
    default:
        break
    }
    return .unknown(raw: line)
}

// 2.3
func mass(of entry: ManifestEntry) -> Int {
    switch entry {
    case let .crate(_, massKg):
        return massKg
    case let .container(_, massKg):
        return massKg
    case let .livestock(_, count, massPerUnitKg):
        return count * massPerUnitKg
    case .unknown:
        return 0
    }
}

print("\nLevel 2: Manifest Parsing")
var totalManifestMass = 0
var unknownCount = 0

for line in rawManifest {
    let entry = parseEntry(line)
    let m = mass(of: entry)
    totalManifestMass += m
    if case .unknown = entry {
        unknownCount += 1
    }
    print("Parsed line: '\(line)' -> Mass: \(m)")
}

print("Total Manifest Mass: \(totalManifestMass)")
print("Unknown Lines Count: \(unknownCount)")

let A = totalManifestMass


// MARK: Level 3 · Crew Snapshots

// 3.1
struct CrewSnapshot {
    let name: String
    var deck: Deck
    var oxygen: Int

    mutating func breathe(amount: Int) {
        oxygen = max(0, oxygen - amount)
    }

    mutating func move(to deck: Deck) {
        self.deck = deck
    }

    mutating func reviveInMedbay() {
        self = CrewSnapshot(name: self.name, deck: .medbay, oxygen: 100)
    }

    static func rookie(named name: String) -> CrewSnapshot {
        return CrewSnapshot(name: name, deck: .bridge, oxygen: 100)
    }
}

// 3.2
print("\nLevel 3.2: Crew Roster")
var crewRoster: [CrewSnapshot] = []
for record in crewData {
    if let deck = Deck(rawValue: record.deck) {
        crewRoster.append(CrewSnapshot(name: record.name, deck: deck, oxygen: record.oxygen))
    } else {
        print("Warning: Deck '\(record.deck)' invalid for crew member \(record.name).")
    }
}
print("Parsed Roster Count: \(crewRoster.count)")

// 3.3 · Value-semantics demonstration
print("\nLevel 3.3: Value Semantics Demonstration")

// copy
var originalCopyTest = CrewSnapshot(name: "Test1", deck: .lab, oxygen: 80)
var mutatedCopy = originalCopyTest
mutatedCopy.breathe(amount: 20)
print("1. Copy Mutation - Original Oxygen: \(originalCopyTest.oxygen) (expected 80)")
print("1. Copy Mutation - Copy Oxygen: \(mutatedCopy.oxygen) (expected 60)")

// non-inout
func passByValue(_ snapshot: CrewSnapshot) {
    var local = snapshot
    local.breathe(amount: 30)
    print("2. Non-Inout Pass - Inside function local oxygen: \(local.oxygen)")
}
var nonInoutTest = CrewSnapshot(name: "Test2", deck: .engine, oxygen: 70)
print("2. Non-Inout Pass - Before function: \(nonInoutTest.oxygen)")
passByValue(nonInoutTest)
print("2. Non-Inout Pass - After function: \(nonInoutTest.oxygen) (expected 70)")

// inout
func passByInout(_ snapshot: inout CrewSnapshot) {
    snapshot.breathe(amount: 30)
}
var inoutTest = CrewSnapshot(name: "Test3", deck: .bridge, oxygen: 90)
print("3. Inout Pass - Before function: \(inoutTest.oxygen)")
passByInout(&inoutTest)
print("3. Inout Pass - After function: \(inoutTest.oxygen) (expected 60)")


// MARK: Level 4 · The Teleport Pod

// 4.1
final class TeleportPod {
    let id: String
    var chargeLevel: Int
    var occupant: CrewSnapshot?

    init(id: String, chargeLevel: Int) {
        self.id = id
        self.chargeLevel = chargeLevel
        self.occupant = nil
    }

    func load(crew: CrewSnapshot) -> Bool {
        guard occupant == nil, chargeLevel >= 20 else { return false }
        occupant = crew
        return true
    }

    func fire() -> CrewSnapshot? {
        guard let crew = occupant else { return nil }
        chargeLevel -= 20
        occupant = nil
        return crew
    }

    deinit {
        print("Deinit triggered for TeleportPod \(id)")
    }
}

// 4.2 · Charge ledger
print("\n--- Level 4.2: Charge Ledger ---")
let pod = TeleportPod(id: "P-1", chargeLevel: 100)

let timur = CrewSnapshot(name: "Timur", deck: .engine, oxygen: 62)
let dana = CrewSnapshot(name: "Dana", deck: .lab, oxygen: 48)
let nurlan = CrewSnapshot(name: "Nurlan", deck: .cargo, oxygen: 17)

_ = pod.load(crew: timur)
_ = pod.fire()
print("Charge after 1st fire (Timur): \(pod.chargeLevel)")

_ = pod.load(crew: dana)
_ = pod.fire()
print("Charge after 2nd fire (Dana): \(pod.chargeLevel)")

_ = pod.load(crew: nurlan)
_ = pod.fire()
print("Charge after 3rd fire (Nurlan): \(pod.chargeLevel)")

_ = pod.fire()
print("Charge after 4th fire (empty): \(pod.chargeLevel)")

let C = pod.chargeLevel

// 4.3 · Reference-semantics demonstration
print("\n--- Level 4.3: Reference Semantics Proof ---")
let refPodA = TeleportPod(id: "RefPod", chargeLevel: 80)
let refPodB = refPodA
refPodB.chargeLevel = 50
print("Class Reference Proof - Pod A charge: \(refPodA.chargeLevel), Pod B charge: \(refPodB.chargeLevel)")

var structSnapA = CrewSnapshot(name: "ValueSnap", deck: .bridge, oxygen: 100)
var structSnapB = structSnapA
structSnapB.oxygen = 40
print("Struct Value Proof - Snap A oxygen: \(structSnapA.oxygen), Snap B oxygen: \(structSnapB.oxygen)")


// MARK: Level 5 · Station Systems

// 5.1
final class Station {
    let callSign: String

    var hullIntegrity: Int {
        willSet {
            print("Hull integrity changing from \(hullIntegrity) to \(newValue)")
        }
        didSet {
            let clamped = max(0, min(100, hullIntegrity))
            if hullIntegrity != clamped {
                hullIntegrity = clamped
            }
        }
    }

    lazy var fullDiagnostics: String = {
        print("Running full scan...")
        return "Diagnostics Complete: All systems operational."
    }()

    var oxygenByDeck: [Deck: Int] = [:]

    var totalOxygen: Int {
        var sum = 0
        for (_, oxy) in oxygenByDeck {
            sum += oxy
        }
        return sum
    }

    var averageOxygen: Int {
        get {
            guard !oxygenByDeck.isEmpty else { return 0 }
            return totalOxygen / oxygenByDeck.count
        }
        set {
            for deck in oxygenByDeck.keys {
                oxygenByDeck[deck] = newValue
            }
        }
    }

    init(callSign: String, hullIntegrity: Int, readings: [(deck: String, oxygen: Int)]) {
        self.callSign = callSign
        self.hullIntegrity = hullIntegrity
        for reading in readings {
            if let deck = Deck(rawValue: reading.deck) {
                self.oxygenByDeck[deck] = reading.oxygen
            }
        }
    }
}

print("\n--- Level 5.1: Station Systems ---")
let station = Station(callSign: "ALMA-7", hullIntegrity: 100, readings: deckReadings)
print("Initial Station Average Oxygen: \(station.averageOxygen)")
let B = station.averageOxygen

print("Accessing lazy property now:")
print(station.fullDiagnostics)
print("Accessing lazy property second time (should NOT print 'Running full scan...'):")
print(station.fullDiagnostics)

// 5.2 · The clamp trap
print("\n--- Level 5.2: Clamp Trap ---")
station.hullIntegrity = 130
print("Hull Integrity after 130: \(station.hullIntegrity)")
station.hullIntegrity = -40
print("Hull Integrity after -40: \(station.hullIntegrity)")
station.hullIntegrity = 55
print("Hull Integrity after 55: \(station.hullIntegrity)")


// MARK: Level 6 · Incident Reports

print("\n--- Level 6: Incident Reports Fixes ---")

// Report 1
var roster = crewRoster
for index in roster.indices {
    roster[index].oxygen -= 10
}
print("Report 1 Fixed Roster[0] Oxygen: \(roster[0].oxygen)")

// Report 2
let podA = TeleportPod(id: "A", chargeLevel: 100)
let podB = TeleportPod(id: "B", chargeLevel: 100)
podB.chargeLevel = 0
print("Report 2 Fixed Pod A charge: \(podA.chargeLevel)")

// Report 3
struct Logbook {
    var entries: [String] = []
    mutating func add(_ entry: String) {
        entries.append(entry)
    }
}
var log = Logbook()
log.add("Entry 1")
print("Report 3 Fixed Entries Count: \(log.entries.count)")

// Report 4
var snapshotReport4 = CrewSnapshot.rookie(named: "Dana")
snapshotReport4.oxygen = 40

let podReport4 = TeleportPod(id: "B", chargeLevel: 50)
podReport4.chargeLevel = 10
print("Report 4 Fixed: Snapshot Oxygen: \(snapshotReport4.oxygen), Pod Charge: \(podReport4.chargeLevel)")


// MARK: Level 7 · Sealing the Black Box

private var _entriesStorage: [String] = []

final class FlightRecorder {
    private(set) var entries: [String] = []
    private(set) var isSealed = false

    fileprivate var securityCheckCode: String {
        return "SEC-\(entries.count)-\(isSealed)"
    }

    func append(_ entry: String) {
        guard !isSealed else { return }
        entries.append(entry)
    }

    func seal() {
        isSealed = true
    }

    var transcript: String {
        var result = "--- TRANSCRIPT ---"
        for entry in entries {
            result += "\n" + entry
        }
        return result
    }
}

func auditTranscript(of recorder: FlightRecorder) -> String {
    return "Audit [Code: \(recorder.securityCheckCode)]: Total Entries = \(recorder.entries.count)"
}

print("\n--- Level 7: Flight Recorder Test ---")
let recorder = FlightRecorder()
recorder.append("Log 1: Teleporter active")
recorder.append("Log 2: Anomaly detected")
print("Transcript before sealing:\n\(recorder.transcript)")
print(auditTranscript(of: recorder))

recorder.seal()
recorder.append("Log 3: Unwanted attempt")
print("Entries after sealed append attempt: \(recorder.entries.count)")


// MARK: Finale · Integrity Code

print("\n--- Finale: Integrity Code ---")
let D = AlarmLevel.level(forTotalMass: A).rawValue
let integrityCode = "\(A)-\(B)-\(C)-\(D)"
print("INTEGRITY CODE: \(integrityCode)")


// MARK: Bonus

print("\n--- Bonus ---")

print("Before do-block scope")
var persistentRef: TeleportPod?
do {
    let scopedPod = TeleportPod(id: "Scoped-101", chargeLevel: 100)
    persistentRef = scopedPod
    print("Inside do-block scope")
}
print("After exiting do-block scope (deinit has NOT fired yet due to persistentRef)")
persistentRef = nil
print("After clearing persistentRef")

func isSamePodInstance(_ pod1: TeleportPod, _ pod2: TeleportPod) -> Bool {
    return pod1 === pod2
}

let podX = TeleportPod(id: "X", chargeLevel: 100)
let podY = podX
let podZ = TeleportPod(id: "X", chargeLevel: 100)

print("podX === podY: \(isSamePodInstance(podX, podY))") // true
print("podX === podZ: \(isSamePodInstance(podX, podZ))") // false


// MARK: - ================= DEFENSE QUESTIONS =================
/*
1. Why did CrewSnapshot get an initializer for free and TeleportPod did not?
 Structs in Swift automatically receive a memberwise initializer generated by
 the compiler for all stored properties if no custom initializers are declared.
 Classes do not receive automatic memberwise initializers (only a default zero-argument
 init if all properties have default values); therefore, classes require explicit initializers.

2. What does `mutating` do to self, and why do classes never need it?
 Marking a struct method as `mutating` tells Swift that calling this function
 modifies the value/properties of `self`, requiring copy-on-write or reassignment
 behavior for value semantics. Classes do not need `mutating` because class instances
 reside on the heap; mutating properties alters the underlying object pointed to,
 rather than replacing the value reference itself.

3. In Report 4 both values are `let`. What exactly does `let` freeze for a
    struct, and what does it freeze for a class?
    For a struct (value type), `let` freezes the value entirely, rendering all of its
    properties immutable regardless of whether they were declared with `var`.
    For a class (reference type), `let` freezes the object reference (pointer),
    meaning you cannot reassign the variable to point to a different class instance.
    However, properties declared with `var` on that instance remain fully mutable.

4. Why must a lazy property be var? When does lazy change behaviour, not
    just performance?
    A `lazy` property must be `var` because its initial value is not computed during
    object initialization; it is assigned on first access, which mutates the underlying instance.
    `lazy` changes behavior when the initialization expression relies on side effects, dynamic external
    state, or instance properties (`self`) that are not fully available until after initialization completes.

5. private vs fileprivate: where in your FlightRecorder would private be
    too strict?
    `private` limits visibility strictly to the enclosing type declaration (and extensions within the same
    file). `fileprivate` extends visibility to any scope within the same source file.
    `private` would be too strict for `securityCheckCode` because the top-level free function
    `auditTranscript(of:)` resides outside the `FlightRecorder` class declaration and needs access
    to read this internal state.

Bonus. On which line does deinit fire, and why can't === be used on
 CrewSnapshot?
 `deinit` fires on the line `persistentRef = nil`, where the last remaining strong reference to the class
 instance is released and reference count drops to 0.
 `===` (identity operator) checks if two reference pointers refer to the exact same heap memory object.
 It cannot be used on `CrewSnapshot` because structs are value types stored without heap object identity pointers.
*/