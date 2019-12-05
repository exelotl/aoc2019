import parsecsv
import strutils

type
  Program = seq[int]
  
  Op = object
    code: Opcode
    modes: seq[ParamMode]
  
  Opcode = enum
    opAdd = 1
    opMul = 2
    opRead = 3
    opWrite = 4
    opJumpIfTrue = 5
    opJumpIfFalse = 6
    opLessThan = 7
    opEquals = 8
    opQuit = 99
  
  ParamMode = enum
    pmPos = 0
    pmImm = 1

proc argCount(op:Opcode): int =
  case op
  of opAdd: 3
  of opMul: 3
  of opRead: 1
  of opWrite: 1
  of opJumpIfTrue: 2
  of opJumpIfFalse: 2
  of opLessThan: 3
  of opEquals: 3
  of opQuit: 0

proc splitDigits(n:int): seq[int] =
  var n = n
  for i in 0..<5:
    result.add(n mod 10)
    n = n div 10

proc parseOp(n:int): Op =
  let a = splitDigits(n)
  result.code = (a[0] + a[1]*10).Opcode
  for i in 0..<argCount(result.code):
    result.modes.add(a[2+i].ParamMode)

proc execute(prog: var Program, pc: var int): bool =
  let op = parseOp(prog[pc])
  
  template arg(n:int):int =
    case op.modes[n]
    of pmPos: prog[(pc+1) + n]
    of pmImm: (pc+1) + n
  
  template advance() =
    pc += (1 + argCount(op.code))
  
  case op.code
  of opAdd:
    prog[arg(2)] = prog[arg(0)] + prog[arg(1)]
    advance()
  of opMul:
    prog[arg(2)] = prog[arg(0)] * prog[arg(1)]
    advance()
  of opRead:
    prog[arg(0)] = stdin.readLine().parseInt()
    advance()
  of opWrite:
    echo $prog[arg(0)]
    advance()
  of opJumpIfTrue:
    if prog[arg(0)] != 0:
      pc = prog[arg(1)]
    else:
      advance()
  of opJumpIfFalse:
    if prog[arg(0)] == 0:
      pc = prog[arg(1)]
    else:
      advance()
  of opLessThan:
    prog[arg(2)] = if prog[arg(0)] < prog[arg(1)]: (1) else: (0)
    advance()
  of opEquals:
    prog[arg(2)] = if prog[arg(0)] == prog[arg(1)]: (1) else: (0)
    advance()
  of opQuit:
    return false
  return true

proc run(prog: var Program) =
  var pc = 0
  while execute(prog, pc):
    discard

proc loadProgram(filename: string): Program =
  var p: CsvParser
  p.open(filename)
  doAssert p.readRow()
  for n in items(p.row):
    result.add(parseInt(n))
  p.close()

var program = loadProgram("input.txt")
program.run()
