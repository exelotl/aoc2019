import parsecsv
import strutils

proc loadProgram(filename: string): seq[int] =
  var p: CsvParser
  p.open(filename)
  doAssert p.readRow()
  for n in items(p.row):
    result.add(parseInt(n))
  p.close()

proc execute(prog: var seq[int], n: var int): bool =
  let op = prog[n]
  case op
  of 1:
    prog[prog[n+3]] = prog[prog[n+1]] + prog[prog[n+2]]
  of 2:
    prog[prog[n+3]] = prog[prog[n+1]] * prog[prog[n+2]]
  of 99:
    return false
  else:
    raiseAssert("invalid opcode " & $op)
  n += 4
  return true

proc run(prog: var seq[int], noun, verb: int): int =
  var pc = 0
  prog[1] = noun
  prog[2] = verb
  while execute(prog, pc):
    discard
  return prog[0]


let program = loadProgram("input.txt")

block part1:
  var p = program
  echo p.run(12, 2)

block part2:
  let maxAddr = program.len - 1
  for noun in 0..maxAddr:
    for verb in 0..maxAddr:
      var p = program
      if p.run(noun, verb) == 19690720:
        echo noun * 100 + verb
        break part2
  
  raiseAssert("no combination found :(")
