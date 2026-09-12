var firstName:String = "Aruzhan"
var lastName:String = "Gazhbek"
let birthYear:Int = 2006
var isStudent:Bool = true
var height:Double = 1.73

var univer:String = "Kbtu"
var studyYear:Int = 4

let currentYear:Int = 2026
let age:Int = currentYear - birthYear
print(age)

var hobby:String = "Working-out and Reading book"
var numberOfHobbies:Int = 2
var favoriteNumber:Int = 12
var isHobbyCreative:Bool = false

var favoriteColor: String = "Blue and White"
var sibilingsNumber:Int = 4

var futureGoals: String = "become a top iOS developer"

let lifeStory: String = """
My name is \(firstName) \(lastName). I am \(age) years old, born in \(birthYear). \
I am currently a student at \(univer) in year \(studyYear). My height is \(height)m. \
I enjoy \(hobby), which is \(isHobbyCreative ? "a creative" : "not a creative") hobby. \
I have \(numberOfHobbies) hobbies in total, and my favorite number is \(favoriteNumber). \
My main goal for the future is to \(futureGoals) .
"""

print(lifeStory)
