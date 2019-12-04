type
  PwChecker = proc (s:string): bool

proc check1(s: string): bool =
  var hasDoubleDigits = false
  var prev = s[0]
  for c in s[1..^1]:
    if c == prev:
      hasDoubleDigits = true
    if ord(c) < ord(prev):
      return false
    prev = c
  return hasDoubleDigits

proc check2(s: string): bool =
  var hasDoubleDigits = false
  var count = 0
  var prev = s[0]
  for c in s[1..^1]:
    if c == prev:
      inc count
    else:
      if count == 1:
        hasDoubleDigits = true
      count = 0
    if ord(c) < ord(prev):
      return false
    prev = c
  if count == 1:
    hasDoubleDigits = true
  return hasDoubleDigits

proc countPasswords(r: Slice[int], fn: PwChecker): int =
  for n in r:
    if fn($n): inc result

echo countPasswords(382345..843167, check1)
echo countPasswords(382345..843167, check2)
