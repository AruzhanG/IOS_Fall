let studentGrades: [String: [Int]] = [
    "Arman": [67,87,95],
    "Nurai": [89,88,93],
    "Erasyl": [90,78,69]
]

let studentName = "Almas"

if let grades = studentGrades[studentName], grades.count >= 2 {
    print("\(studentName)'s second grade is: \(grades[1])")
}else{
    print("Student not found or doesn't have at least 2 grades.")
}