import times, math

var
    comparisons*: int = 0
    swaps*: int = 0

iterator bubbleSort*(lijst: var seq[int]): int =
  let n = lijst.len
  for i in 0..<n:
    for j in 0..<n - i - 1:
        inc(comparisons)
        if lijst[j] > lijst[j+1]:
            swap(lijst[j], lijst[j+1])
            inc(swaps)
            yield j

iterator selectionSort*(lijst: var seq[int]): int =
    let n = lijst.len

    for i in 0 ..< n - 1:
        var minIndex = i

        for j in i + 1..<n:
            inc(comparisons)
            if lijst[j] < lijst[minIndex]:
                minIndex = j 
            yield j    
        if minIndex != i:       
            swap(lijst[i], lijst[minIndex])
            inc(swaps)
            yield i

iterator insertionSort*(lijst: var seq[int]): int =
    let n = lijst.len
    for i in 1..<n:
        var sleutel = lijst[i]
        var j = i - 1

        inc(comparisons)
        while j >= 0 and lijst[j] > sleutel:
            lijst[j + 1] = lijst[j]
            inc(swaps)
            yield j
            dec(j)

            if j >= 0:
                inc(comparisons)
            
        lijst[j + 1] = sleutel
        yield i

iterator shellSort*(lijst: var seq[int]): int =
    let n = lijst.len
    var gap = n div 2

    while gap > 0:
        for i in gap..<n:
            var sleutel = lijst[i]
            var j = i
            inc(comparisons)

            while j >= gap and lijst[j - gap] > sleutel:
                lijst[j] = lijst[j - gap]
                j = j - gap
                yield j

                if j >= gap:
                    inc(comparisons)
            lijst[j] = sleutel
            inc(swaps)
            yield j
   
        gap = gap div 2

iterator mergeSort*(lijst: var seq[int]): int =
  let n = lijst.len
  var size = 1
  
  while size < n:
    for links in countup(0, n - 1, 2 * size):
      let midden = min(links + size - 1, n - 1)
      let rechts = min(links + 2 * size - 1, n - 1)
      
      var linksDeel = lijst[links..midden]
      var rechtsDeel = lijst[midden+1..rechts]
      
      var i = 0
      var j = 0
      var k = links
      
      while i < linksDeel.len and j < rechtsDeel.len:
        inc(comparisons)
        if linksDeel[i] <= rechtsDeel[j]:
          lijst[k] = linksDeel[i]
          inc(i)
        else:
          lijst[k] = rechtsDeel[j]
          inc(j)

        inc(swaps)
        yield k
        inc(k)
        
      while i < linksDeel.len:
        lijst[k] = linksDeel[i]
        inc(i)
        inc(swaps)
        yield k
        inc(k)
        
      while j < rechtsDeel.len:
        lijst[k] = rechtsDeel[j]
        inc(j)
        inc(swaps)
        yield k
        inc(k)
        
    size = size * 2

iterator quickSort*(lijst: var seq[int]): int =
  let n = lijst.len
  var stack: seq[(int, int)] = @[(0, n - 1)]

  while stack.len > 0:
    let (laag, hoog) = stack.pop()
    
    if laag < hoog:
      
      let pivot = lijst[hoog]
      var i = laag
      
      for j in laag ..< hoog:
        inc(comparisons)
        if lijst[j] <= pivot:
          swap(lijst[i], lijst[j])
          inc(swaps)
          yield i
          inc(i)
      
      swap(lijst[i], lijst[hoog])
      inc(swaps)
      yield i 
      let p = i
      
      stack.add((laag, p - 1))
      stack.add((p + 1, hoog))

iterator stalinSort*(lijst: var seq[int]): int =
    var huidigeMax = lijst[0]

    for i in 1 ..< lijst.len:
        inc(comparisons)
        if lijst[i] >= huidigeMax:
            huidigeMax = lijst[i]
            yield i
        else:
            lijst[i] = 0 
            yield i

iterator svenSort*(lijst: var seq[int], maxTime: float): int =
    let n = lijst.len
    let s = epochTime()

    block mainLoop:
        for i in 0..<n:
            for j in 0..<n - i - 1:
                inc(comparisons)
                if epochTime() - s > maxTime:
                    for pos in stalinSort(lijst):
                        yield pos
                    break mainLoop

                if lijst[j] > lijst[j+1]:
                    swap(lijst[j], lijst[j+1])
                    inc(swaps)
                    yield j

iterator radixSort*(lijst: var seq[int]): int =
    let maxNumber = max(lijst)
    var exponent = 1

    while (maxNumber div exponent > 0):
        var buckets: array[10, seq[int]]
        for i in 0..<lijst.len: 
            let 🪣 = (lijst[i] div exponent) mod 10 #🪣 = bucketIndex
            buckets[🪣].add(lijst[i])
            yield i

        var 👉 = 0 #👉 = index
        for b in 0..9:
            for number in buckets[b]:
                lijst[👉] = number
                inc(swaps)
                yield 👉
                inc(👉)

        exponent *= 10

iterator heapSort*(lijst: var seq[int]): int =
    let n = lijst.len

    for i in countdown(n div 2 - 1, 0): #🧒 = child, 🤦‍♂️ = parent
        var 🤦‍♂️ = i
        while true:
            var 🧒 = 2 * 🤦‍♂️ + 1
            if 🧒 >= n:
                break 
            inc(comparisons)
            if (🧒 + 1 < n) and (lijst[🧒] < lijst[🧒 + 1]):
                🧒 += 1
            inc(comparisons)
            if lijst[🤦‍♂️] < lijst[🧒]:
                swap(lijst[🤦‍♂️], lijst[🧒])
                inc(swaps)
                yield 🧒
                🤦‍♂️ = 🧒
            else:
                break

    for i in countdown(n - 1, 1): 
        inc(comparisons)
        swap(lijst[0], lijst[i])
        inc(swaps)
        yield i

        var 🤦‍♂️ = 0
        while true:
            var 🧒 = 2 * 🤦‍♂️ + 1
            if 🧒 >= i:
                break
            inc(comparisons)
            if (🧒 + 1 < i) and (lijst[🧒] < lijst[🧒 + 1]):
                🧒 += 1
            inc(comparisons)
            if lijst[🤦‍♂️] < lijst[🧒]:
                swap(lijst[🤦‍♂️], lijst[🧒])
                inc(swaps)
                yield 🧒
                🤦‍♂️ = 🧒 
            else:
                break

proc calculatePower(s1, e1, s2, e2, n: int): int =
    let m1 = (s1.float + e1.float) / 2.0
    let m2 = (s2.float + e2.float) / 2.0
    var a = m1 / n.float
    var b = m2 / n.float
    result = 0

    while floor(a * 2.0) == floor(b * 2.0):
        a = (a * 2.0) - floor(a * 2.0)
        b = (b * 2.0) - floor(b * 2.0)
        inc(result)

iterator powerSort*(lijst: var seq[int]): int =
  let n = lijst.len

  var stack: seq[tuple[start, einde, power: int]] = @[]
  var huidigeStart = 0

  while huidigeStart < n:
    var eindeRun = huidigeStart

    if eindeRun < n - 1:
      inc(eindeRun)
      inc(comparisons)
      if lijst[eindeRun] < lijst[huidigeStart]:
        while eindeRun < n - 1 and lijst[eindeRun + 1] < lijst[eindeRun]:
          inc(comparisons)
          inc(eindeRun)

        var a = huidigeStart
        var b = eindeRun

        while a < b:
          swap(lijst[a], lijst[b])
          inc(swaps)
          yield a
          inc(a)
          dec(b)
      else:
        while eindeRun < n - 1 and lijst[eindeRun + 1] >= lijst[eindeRun]:
          inc(comparisons)
          inc(eindeRun)

    let volgendeStart = eindeRun + 1

    if stack.len > 0:
      let p = calculatePower(stack[^1].start, stack[^1].einde, huidigeStart, eindeRun, n)
      
      while stack.len >= 1 and stack[^1].power >= p:
        let rechts = (start: huidigeStart, einde: eindeRun)
        let links = stack.pop()
        
        var linksDeel = lijst[links.start..links.einde]
        var rechtsDeel = lijst[rechts.start..rechts.einde]
        var i = 0
        var j = 0
        var k = links.start
        
        while i < linksDeel.len and j < rechtsDeel.len:
            inc(comparisons)
            let v = if linksDeel[i] <= rechtsDeel[j]:
                        let val = linksDeel[i]
                        inc(i)
                        val
                    else:
                        let val = rechtsDeel[j]
                        inc(j)
                        val
            
            if lijst[k] != v:
                lijst[k] = v
                inc(swaps)
                yield k
            inc(k)
          
        while i < linksDeel.len:
            if lijst[k] != linksDeel[i]:
                lijst[k] = linksDeel[i]
                inc(swaps)
                yield k
            inc(i)
            inc(k)
          
        while j < rechtsDeel.len:
            if lijst[k] != rechtsDeel[j]:
                lijst[k] = rechtsDeel[j]
                inc(swaps)
                yield k
            inc(j)
            inc(k)
          
        huidigeStart = links.start
        eindeRun = rechts.einde
      
      if stack.len > 0:
        stack[^1].power = p

    stack.add((huidigeStart, eindeRun, 0))
    huidigeStart = volgendeStart

  while stack.len > 1:
    let rechts = stack.pop()
    let links = stack.pop()

    var linksDeel = lijst[links.start..links.einde]
    var rechtsDeel = lijst[rechts.start..rechts.einde]
    var i = 0
    var j = 0
    var k = links.start
    
    while i < linksDeel.len and j < rechtsDeel.len:
            inc(comparisons)
            let v = if linksDeel[i] <= rechtsDeel[j]:
                        let val = linksDeel[i]
                        inc(i)
                        val
                    else:
                        let val = rechtsDeel[j]
                        inc(j)
                        val
            
            if lijst[k] != v:
                lijst[k] = v
                inc(swaps)
                yield k
            inc(k)
          
    while i < linksDeel.len:
        if lijst[k] != linksDeel[i]:
            lijst[k] = linksDeel[i]
            inc(swaps)
            yield k
        inc(i)
        inc(k)

    while j < rechtsDeel.len:
        if lijst[k] != rechtsDeel[j]:
            lijst[k] = rechtsDeel[j]
            inc(swaps)
            yield k
        inc(j)
        inc(k)
      
    stack.add((links.start, rechts.einde, 0))