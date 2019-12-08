import parsecsv
import strutils

proc defaultIn(): int =
  stdin.readLine().parseInt()

proc defaultOut(n:int) =
  echo $n

type
  Runner* = object
    program*: Program
    read*: InputFn
    write*: OutputFn
    isDone*: bool
    pc: int
    shouldWait: bool
  
  Program* = seq[int]
  
  InputFn* = proc(): int
  OutputFn* = proc(n :int)
  
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

proc wait*(r: var Runner) =
  r.shouldWait = true

proc run*(r: var Runner) =
  doAssert(not r.isDone)
  while true:
    let op = parseOp(r.program[r.pc])
    
    template argaddr(n:int):int =
      case op.modes[n]
      of pmPos: r.program[(r.pc + 1) + n]
      of pmImm: (r.pc + 1) + n
    
    template arg(n:int): untyped =
      r.program[argaddr(n)]
    
    case op.code
    of opAdd:
      arg(2) = arg(0) + arg(1)
    of opMul:
      arg(2) = arg(0) * arg(1)
    of opRead:
      arg(0) = r.read()
    of opWrite:
      r.write(arg(0))
    of opJumpIfTrue:
      if arg(0) != 0:
        r.pc = arg(1)
        continue
    of opJumpIfFalse:
      if arg(0) == 0:
        r.pc = arg(1)
        continue
    of opLessThan:
      arg(2) = if arg(0) < arg(1): (1) else: (0)
    of opEquals:
      arg(2) = if arg(0) == arg(1): (1) else: (0)
    of opQuit:
      r.isDone = true
      return
    
    r.pc += (1 + argCount(op.code))
    
    if r.shouldWait:
      r.shouldWait = false
      return

proc run*(program: var Program, read: InputFn = defaultIn, write: OutputFn = defaultOut) =
  var r: Runner
  r.program = program
  r.read = read
  r.write = write
  r.run()

proc loadProgram*(filename: string): Program =
  var p: CsvParser
  p.open(filename)
  doAssert p.readRow()
  for n in items(p.row):
    result.add(parseInt(n))
  p.close()
