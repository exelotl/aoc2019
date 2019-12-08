import intcode
import algorithm

let program = loadProgram("input.txt")

proc tryCombo(a: seq[int]): int =
  var output = 0
  
  for i in 0..<a.len:
    var p = program
    var inputs = @[a[i], output]
    
    proc pRead(): int =
      result = inputs[0]
      inputs.delete(0)
    
    proc pWrite(n: int) =
      output = n
    
    p.run(pRead, pWrite)
  
  return output


proc tryFeedbackCombo(a: seq[int]): int =
  var runners: seq[Runner]
  var output = 0
  
  proc addRunner(i, phase: int) =
    var didInit = false
    
    proc pRead(): int =
      if not didInit:
        didInit = true
        phase
      else:
        output
    
    proc pWrite(n: int) =
      output = n
      runners[i].wait()
    
    runners.add Runner(
      program: program,
      read: pRead,
      write: pWrite
    )
  
  for i, v in a:
    addRunner(i, v)
  
  var i = 0
  while not(runners[i].isDone):
    runners[i].run()
    i = (i+1) mod a.len
  
  return output


proc bestOutput(arr: seq[int], fn: proc(a: seq[int]): int): int =
  var a = arr
  while true:
    let n = fn(a)
    if n > result: result = n
    if not nextPermutation(a): break

echo bestOutput(@[0,1,2,3,4], tryCombo)
echo bestOutput(@[5,6,7,8,9], tryFeedbackCombo)
