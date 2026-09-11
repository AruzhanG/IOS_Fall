let set1: Set<String> = ["cat", "dog"]
let set2: Set<String> = ["dog", "mouse"]

let unionSet = set1.union(set2)

let finalSet = unionSet.subtracting(set2)

print(finalSet)