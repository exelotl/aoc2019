import strutils
import tables

type
  Node = ref object
    parent: Node
    distanceFromStart: int

var map: Table[string, Node]

proc countOrbits(node: Node): int =
  if node.parent != nil:
    1 + countOrbits(node.parent)
  else:
    0

proc getNode(name: string): Node =
  if map.contains(name):
    result = map[name]
  else:
    result = Node(distanceFromStart: -1)
    map[name] = result

for s in lines("input.txt"):
  let parts = s.split(')')
  let a = getNode(parts[0])
  let b = getNode(parts[1])
  b.parent = a

block:
  var total = 0
  for node in values(map):
    total += countOrbits(node)
  echo total

block:
  var distanceFromStart = 0
  var distanceFromTarget = 0
  
  var node = getNode("YOU").parent
  while node != nil:
    node.distanceFromStart = distanceFromStart
    inc distanceFromStart
    node = node.parent
  
  node = getNode("SAN").parent
  while node.distanceFromStart == -1:
    inc distanceFromTarget
    node = node.parent
  
  echo node.distanceFromStart + distanceFromTarget