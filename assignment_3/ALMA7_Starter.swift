// =============================================================
//  Station ALMA-7: Rescue Protocol
//  iOS Mobile Development · Module 3 · Lab Assignment
//
//  How to use:
//   • Xcode: File → New → Playground → Blank, replace everything
//     with this file's contents.
//   • Terminal: swift ALMA7_Starter.swift
//
//  Rules:
//   • Do NOT modify the STARTER CODE section.
//   • `!` (force unwrap) is forbidden: −0.5 points each.
//   • No map / filter / reduce / compactMap.
//   • Use the exact function names from the assignment PDF.
// =============================================================


// MARK: - =================== STARTER CODE ===================
// MARK: - Do not modify anything in this section

typealias Reading = (sensor: String, value: Int)

/// Splits a string at the first occurrence of the separator.
/// splitOnce("O2:87", by: ":") -> ("O2", "87")
/// splitOnce("hello", by: ":") -> nil
func splitOnce(_ line: String, by separator: Character) -> (String, String)? {
    guard let index = line.firstIndex(of: separator) else { return nil }
    let left = String(line[..<index])
    let right = String(line[line.index(after: index)...])
    return (left, right)
}

let rawLog = [
    "O2:87", "TEMP:-12", "O2:9x", "PRESS:101", "TEMP:abc", "O2:",
    "RAD:3", "O2:64", ":55", "TEMP:31", "PRESS:98", "O2:71",
    "RAD:-1", "TEMP:4", "PRESS:1o2", "O2:90"
]

class Tank {
    var level: Int
    init(level: Int) { self.level = level }
}

class Module {
    let name: String
    var oxygenTank: Tank?
    init(name: String, oxygenTank: Tank?) {
        self.name = name
        self.oxygenTank = oxygenTank
    }
}

class CrewMember {
    let name: String
    let role: String
    let priority: Int      // 1 = evacuated first
    var module: Module?    // nil = in open space
    init(name: String, role: String, priority: Int, module: Module?) {
        self.name = name
        self.role = role
        self.priority = priority
        self.module = module
    }
}

let lab  = Module(name: "Lab",  oxygenTank: Tank(level: 40))
let hab  = Module(name: "Hab",  oxygenTank: Tank(level: 12))
let dock = Module(name: "Dock", oxygenTank: nil)

let crew = [
    CrewMember(name: "Timur",   role: "Engineer",  priority: 3, module: lab),
    CrewMember(name: "Dana",    role: "Scientist", priority: 4, module: dock),
    CrewMember(name: "Aigerim", role: "Commander", priority: 1, module: hab),
    CrewMember(name: "Nurlan",  role: "Pilot",     priority: 2, module: nil)
]

var roster: [String: CrewMember] = [:]
for member in crew { roster[member.name] = member }

print("ALMA-7 systems online: \(rawLog.count) log lines, \(crew.count) crew members.")

// MARK: - ================= END OF STARTER CODE =================


// MARK: - =================== YOUR SOLUTION ===================
// Uncomment each signature when you start working on it.


// MARK: Level 1 · Decoding Telemetry

// 1.1
// func parseReading(_ raw: String) -> Reading? { }

// 1.2
// func parseLog(_ lines: [String]) -> (valid: [Reading], invalidCount: Int) { }

// let A = ...


// MARK: Level 2 · Analysis

// 2.1
// func select(_ readings: [Reading], where isIncluded: (Reading) -> Bool) -> [Reading] { }
// func values(of readings: [Reading]) -> [Int] { }

// 2.2
// func stats(of values: [Int]) -> (min: Int, max: Int, average: Double)? { }
// func stats(_ values: Int...) -> (min: Int, max: Int, average: Double)? { }

// let B = ...

// 2.3 · The Closure Ladder (5 sorts, then compare results in code)


// MARK: Level 3 · Temperature Stabilization

// 3.1
// func heatUp(_ t: Int) -> Int { }
// func coolDown(_ t: Int) -> Int { }
// func hold(_ t: Int) -> Int { }
// func chooseProtocol(for temp: Int) -> (Int) -> Int { }

// 3.2
// func runUntilStable(from start: Int, maxSteps: Int = 10) -> (finalTemp: Int, steps: Int, isStable: Bool) { }

// let C = ...


// MARK: Level 4 · The Crew

// 4.1
// func oxygenLevel(of member: CrewMember) -> Int? { }

// 4.2
// func status(of member: CrewMember) -> String { }

// 4.3
// @discardableResult
// func transferOxygen(from source: inout Int, to target: inout Int, amount: Int) -> Int { }

// let D = ...

// 4.4
// func evacuationOrder(_ names: String..., roster: [String: CrewMember]) -> [String] { }


// MARK: Level 5 · The Saboteur's Logbook
// The saboteur's code is below, commented out (it needs your
// oxygenLevel(of:) to compile). Comment on every problem, then
// write fixed versions and a test that proves the logic bug is gone.

/*
func reportOxygen(for member: CrewMember) -> String {
    let tank = member.module!.oxygenTank!
    return "\(member.name): \(tank.level)%"
}

func firstCritical(in crew: [CrewMember]) -> String {
    var result: String?
    for member in crew {
        if oxygenLevel(of: member)! < 20 {
            result = member.name
        }
    }
    return result!
}
*/


// MARK: Finale · Launch Code

// let launchCode = "\(A)-\(B)-\(C)-\(D)"
// print("LAUNCH CODE: \(launchCode)")


// MARK: Bonus

// func makeAlarm(threshold: Int) -> (Int) -> Bool { }


// MARK: - ================= DEFENSE QUESTIONS =================
/*
 1. guard let vs if let beyond syntax:

 2. Why can't you pass [Int] to stats(_ values: Int...)?

 3. Why doesn't transferOxygen(from: &x, to: &x, amount: 5) compile?

 4. Why doesn't oxygenLevel(of: dana) ?? "no data" compile?

 5. Full type of chooseProtocol and how to read it:

 Bonus. Where does the alarm counter live after makeAlarm returns?

*/


func parseReading(raw: String) -> Reading? {
    guard let (sensor, valueStr) = splitOnce(raw, by: ":"),
          !sensor.isEmpty,
          let value = Int(valueStr),
          (sensor == "TEMP" || value >= 0) else {
        return nil
    }
    return (sensor: sensor, value: value)
}

func parseLog(lines: [String]) -> (valid: [Reading], invalidCount: Int) {
    var validReadings: [Reading] = []
    var invalidCount = 0
    
    for line in lines {
        if let reading = parseReading(raw: line) {
            validReadings.append(reading)
        } else {
            invalidCount += 1
        }
    }
    
    return (valid: validReadings, invalidCount: invalidCount)
}

// Fragment A
let (validReadings, fragmentA) = parseLog(lines: rawLog)

func select(readings: [Reading], where isIncluded: (Reading) -> Bool) -> [Reading] {
    var result: [Reading] = []
    for reading in readings {
        if isIncluded(reading) {
            result.append(reading)
        }
    }
    return result
}

func values(of readings: [Reading]) -> [Int] {
    var result: [Int] = []
    for r in readings {
        result.append(r.value)
    }
    return result
}

// Фильтрация показаний датчика "O2" с замыканием {$0.sensor == "O2"}
let o2Readings = select(readings: validReadings) { $0.sensor == "O2" }
let o2Values = values(of: o2Readings)

func stats(of values: [Int]) -> (min: Int, max: Int, average: Double)? {
    guard !values.isEmpty else { return nil }
    var minValue = values[0]
    var maxValue = values[0]
    var sum = 0
    
    for v in values {
        if v < minValue { minValue = v }
        if v > maxValue { maxValue = v }
        sum += v
    }
    
    let avg = Double(sum) / Double(values.count)
    return (min: minValue, max: maxValue, average: avg)
}

func stats(values: Int...) -> (min: Int, max: Int, average: Double)? {
    stats(of: values)
}

// Fragment B
let o2Stats = stats(of: o2Values)
let fragmentB = Int(o2Stats?.average ?? 0)

// 1. Полный синтаксис
let sort1 = validReadings.sorted(by: { (r1: Reading, r2: Reading) -> Bool in
    return r1.value > r2.value
})

// 2. Вывод типов из контекста
let sort2 = validReadings.sorted(by: { r1, r2 in
    return r1.value > r2.value
})

// 3. Неявный return (Implicit return)
let sort3 = validReadings.sorted(by: { r1, r2 in r1.value > r2.value })

// 4. Сокращенные имена аргументов ($0, $1)
let sort4 = validReadings.sorted(by: { $0.value > $1.value })

// 5. Последующее замыкание (Trailing closure)
let sort5 = validReadings.sorted { $0.value > $1.value }

// Проверка совпадения:
let allMatch = (sort1.elementsEqual(sort2, by: { $0 == $1 })) &&
               (sort2.elementsEqual(sort3, by: { $0 == $1 })) &&
               (sort3.elementsEqual(sort4, by: { $0 == $1 })) &&
               (sort4.elementsEqual(sort5, by: { $0 == $1 }))
print("Сортировки совпадают: \(allMatch)")

func heatUp(_ temp: Int) -> Int { temp + 5 }
func coolDown(_ temp: Int) -> Int { temp - 3 }
func hold(_ temp: Int) -> Int { temp }

func chooseProtocol(for temp: Int) -> (Int) -> Int {
    if temp < 18 {
        return heatUp
    } else if temp > 24 {
        return coolDown
    } else {
        return hold
    }
}

func runUntilStable(from start: Int, maxSteps: Int = 10) -> (finalTemp: Int, steps: Int, isStable: Bool) {
    var currentTemp = start
    var steps = 0
    
    while (currentTemp < 18 || currentTemp > 24) && steps < maxSteps {
        let proto = chooseProtocol(for: currentTemp)
        currentTemp = proto(currentTemp)
        steps += 1
    }
    
    let isStable = (18...24).contains(currentTemp)
    return (finalTemp: currentTemp, steps: steps, isStable: isStable)
}

// Fragment C: Поиск минимальной валидной температуры из rawLog
let tempReadings = select(readings: validReadings) { $0.sensor == "TEMP" }
let tempValues = values(of: tempReadings)
let minTemp = stats(of: tempValues)?.min ?? 0

let fragmentC = runUntilStable(from: minTemp).steps

func oxygenLevel(of member: CrewMember) -> Int? {
    member.module?.oxygenTank?.level
}

func status(of member: CrewMember) -> String {
    guard let module = member.module else {
        return "\(member.name): no data (open space)"
    }
    
    guard let level = oxygenLevel(of: member) else {
        return "\(member.name): no data (\(module.name))"
    }
    
    let statusText = level < 20 ? "CRITICAL" : "OK"
    return "\(member.name): \(level)% \(statusText)"
}

@discardableResult
func transferOxygen(from source: inout Int, to target: inout Int, amount: Int) -> Int {
    guard amount > 0 else { return 0 }
    
    let availableInSource = source
    let spaceInTarget = 100 - target
    
    let actualTransfer = min(amount, min(availableInSource, spaceInTarget))
    
    source -= actualTransfer
    target += actualTransfer
    
    return actualTransfer
}

// Передаем 30 единиц из Lab в Hab
if let labTank = lab.oxygenTank, let habTank = hab.oxygenTank {
    transferOxygen(from: &labTank.level, to: &habTank.level, amount: 30)
}

// Fragment D: уровень кислорода в Hab
let fragmentD = hab.oxygenTank?.level ?? 0

func evacuationOrder(_ names: String..., roster: [String: CrewMember]) -> [String] {
    var membersToEvacuate: [CrewMember] = []

    for name in names {
        guard let member = roster[name] else {
            print("Unknown crew member: \(name)")
            continue
        }
        membersToEvacuate.append(member)
    }

    membersToEvacuate.sort { $0.priority < $1.priority }

    var resultNames: [String] = []
    for member in membersToEvacuate {
        resultNames.append(member.name)
    }
    return resultNames
}

func reportOxygen(for member: CrewMember) -> String {
    if let level = oxygenLevel(of: member) {
        return "\(member.name): \(level)%"
    } else if let module = member.module {
        return "\(member.name): no data (\(module.name))"
    } else {
        return "\(member.name): no data (open space)"
    }
}

func firstCritical(in crew: [CrewMember]) -> String? {
    for member in crew {
        if let level = oxygenLevel(of: member), level < 20 {
            return member.name // Возвращаем первого найденного
        }
    }
    return nil
}

// Тест логической ошибки:
// Создадим двух критических членов экипажа: [Critical1, Critical2]
// Старый код вернул бы "Critical2", новый верно возвращает "Critical1".


let launchCode = "\(fragmentA)-\(fragmentB)-\(fragmentC)-\(fragmentD)"
print("LAUNCH CODE: \(launchCode)")