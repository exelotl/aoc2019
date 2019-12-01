import strutils

proc fuelRequirement(mass:int): int =
  (mass div 3) - 2

proc smartFuelRequirement(mass:int): int =
  result = fuelRequirement(mass)
  var extra = fuelRequirement(result)
  while extra > 0:
    result += extra
    extra = fuelRequirement(extra)

var total: int
var smartTotal: int

for line in lines("input.txt"):
  let mass = parseInt(line)
  total += fuelRequirement(mass)
  smartTotal += smartFuelRequirement(mass)

echo total
echo smartTotal
