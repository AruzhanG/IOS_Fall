let programminglanguages: [String: Int] = [
    "Swift": 2014,
    "Python": 1991,
    "Java": 1995
]

if let SwiftReleaseYear = programminglanguages["Swift"]{
    print("Swift was released in \(SwiftReleaseYear)")
}else {
    print("Key not found")
}