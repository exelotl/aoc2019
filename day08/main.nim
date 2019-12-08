import sequtils

type
  Image = ref object
    width, height: int
    data: seq[uint8]

proc size(img: Image): int = img.width * img.height
proc layers(img: Image): int = img.data.len div img.size

iterator pixels(img: Image, layer=0): tuple[i:int, n:uint8] =
  var base = layer * img.size
  for i in 0 ..< img.size:
    yield (i, img.data[base + i])

proc flatten(img: Image): Image =
  result = Image(
    width: img.width,
    height: img.height,
    data: (2'u8).repeat(img.size),
  )
  for l in countdown(img.layers-1, 0):
    for i, n in pixels(img, l):
      if n == 2: discard
      else: result.data[i] = n

proc render(img: Image): string =
  for i, n in pixels(img):
    if i > 0 and (i mod img.width) == 0:
      result.add '\n'
    result.add case n
      of 0: "█"
      of 1: "▒"
      else: " "

let img = Image(width:25, height:6)
for c in readFile("input.txt"):
  img.data.add (ord(c) - ord('0')).uint8

block:
  var occurrences = newSeq[array[0..2, int]](img.layers)
  for l in 0..<img.layers:
    for _, n in pixels(img, l):
      inc occurrences[l][n]
  
  var leastZerosLayer = -1
  var leastZeros = 999999
  
  for l in 0..<img.layers:
    if occurrences[l][0] < leastZeros:
      leastZeros = occurrences[l][0]
      leastZerosLayer = l
  
  echo occurrences[leastZerosLayer][1] * occurrences[leastZerosLayer][2]

block:
  let res = img.flatten()
  echo res.render()