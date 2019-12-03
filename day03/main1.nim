import parsecsv, tables, strutils

type
  Vec2i = tuple[x, y: int]
  WireStep = tuple[dir:char, dist:int]
  Occupation = enum
    ocNone
    ocWire1
    ocWire2

proc manhattan(vec: Vec2i): int =
  abs(vec.x) + abs(vec.y)


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


var map: Table[Vec2i, set[Occupation]]

proc trace(wire: seq[WireStep], oc: Occupation) =
  var pos: Vec2i
  
  template occupy(increment) =
    for i in 0..<step.dist:
      increment
      map[pos] = map.getOrDefault(pos) + {oc}
  
  for step in wire:
    case step.dir
    of 'U': occupy(pos.y += 1)
    of 'D': occupy(pos.y -= 1)
    of 'L': occupy(pos.x -= 1)
    of 'R': occupy(pos.x += 1)
    else: quit("invalid direction " & step.dir)


trace(wire1, ocWire1)
trace(wire2, ocWire2)

var nearestDist = high(int)

for pos, oc in pairs(map):
  if oc == {ocWire1, ocWire2}:
    let len = manhattan(pos)
    if len < nearestDist:
      nearestDist = len

echo nearestDist