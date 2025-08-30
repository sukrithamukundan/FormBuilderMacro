import MyDemoMacro

let a = 17
let b = 25

let (result, code) = #stringify(a + b)

print("The value \(result) was produced by the code \"\(code)\"")
//The value 42 was produced by the code 17 + 25

