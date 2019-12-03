import parsecsv, tables, strutils

type
  Vec2i = tuple[x, y: int]
  WireStep = tuple[dir:char, dist:int]

var wire1, wire2: seq[WireStep]

block:
  var p: CsvParser
  p.open("input.txt")
  
  doAssert p.readRow()
  for s in items(p.row):
    wire1.add (s[0], parseInt(s[1..^1]))
  
  doAssert p.readRow()
  for s in items(p.row):
    wire2.add (s[0], parseInt(s[1..^1]))
  
  p.close()


proc trace(wire: seq[WireStep], map: var Table[Vec2i, int]) =
  var pos: Vec2i
  var steps = 0
  
  template occupy(increment) =
    for i in 0..<step.dist:
      increment
      steps += 1
      if not map.hasKey(pos):
        map[pos] = steps
  
  for step in wire:
    case step.dir
    of 'U': occupy(pos.y += 1)
    of 'D': occupy(pos.y -= 1)
    of 'L': occupy(pos.x -= 1)
    of 'R': occupy(pos.x += 1)
    else: quit("invalid direction " & step.dir)


var map1: Table[Vec2i, int]
var map2: Table[Vec2i, int]

trace(wire1, map1)
trace(wire2, map2)

var lowestDelay = high(int)

for pos, n1 in pairs(map1):
  if map2.hasKey(pos):
    let n2 = map2[pos]
    let sum = n1 + n2
    if sum < lowestDelay:
      lowestDelay = sum

echo lowestDelay