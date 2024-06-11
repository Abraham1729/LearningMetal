import Metal

// Arrays to add
let array1: [Float] = [1, 2, 3, 4, 5]
let array2: [Float] = [6, 7, 8, 9, 10]
let myAdder = Adder(array1: array1, array2: array2)

print("Checking initial state:")
myAdder.Display()
myAdder.Add()
print("\nChecking final state:")
myAdder.Display()
