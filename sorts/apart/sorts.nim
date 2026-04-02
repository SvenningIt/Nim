import strutils, sequtils, strformat, terminal, times

proc printLijst*[T](prefix: string, x: int, lijst: seq[T]) =
    echo prefix, x, ": ", lijst.mapIt($it).join(". ")

proc bubbleSort*[T](lijst: var seq[T]): seq[T] =
    let n = lijst.len
    var x = 0
    for i in 0..<n:
        if n > 1000 and i mod 100 == 0: 
            let percent = (i * 100) div n
            stdout.write("\r") 
            stdout.resetAttributes()
            stdout.write(&"{percent}% bezig met BubbleSort...\t")
            stdout.flushFile()

        var verwisseld = false
        for j in 0..<n - i - 1:
            if lijst[j] > lijst[j+1]:
                swap(lijst[j], lijst[j+1])
                verwisseld = true
                inc(x)
                if n < 20:
                    printLijst("Stap ", x, lijst)
        if not verwisseld:
            break
    lijst

proc selectionSort*[T](lijst: var seq[T]): seq[T] =
    let n = lijst.len
    var x = 0
    for i in 0..<n:
        if n > 1000 and i mod 100 == 0: 
            let percent = (i * 100) div n
            stdout.write("\r") 
            stdout.resetAttributes()
            stdout.write(&"{percent}% bezig met SelectionSort...\t")
            stdout.flushFile()

        var minIndex = i
        for j in i + 1..<n:
            if lijst[j] < lijst[minIndex]:
                minIndex = j     
        if minIndex != i:       
            swap(lijst[i], lijst[minIndex])
            inc(x)
            if n < 20:
                printLijst("Stap ", x, lijst)
    lijst

proc insertionSort*[T](lijst: var seq[T]): seq[T] =
    let n = lijst.len
    var x = 0
    for i in 1..<n:
        if n > 1000 and i mod 100 == 0: 
            let percent = (i * 100) div n
            stdout.write("\r") 
            stdout.resetAttributes()
            stdout.write(&"{percent}% bezig met InsertionSort...\t")
            stdout.flushFile()

        var sleutel = lijst[i]
        var j = i - 1
        while j >= 0 and lijst[j] > sleutel:
            lijst[j + 1] = lijst[j]
            dec(j)
            inc(x)
            if n < 20:
                printLijst("Stap ", x, lijst)
        lijst[j + 1] = sleutel
    lijst

proc shellSort*[T](lijst: var seq[T]): seq[T] =
    let n = lijst.len
    var gap = n div 2
    var x = 0

    while gap > 0:
        for i in gap..<n:
            var sleutel = lijst[i]
            var j = i
            
            while j >= gap and lijst[j - gap] > sleutel:
                lijst[j] = lijst[j - gap]
                j = j - gap

            lijst[j] = sleutel
            inc(x)
            
        gap = gap div 2
        if n < 20:
            printLijst("Stap ", x, lijst)
    lijst


proc merge[T](links: seq[T], rechts: seq[T]): seq[T] =
    result = @[]
    var l = 0
    var r = 0

    while l < links.len and r < rechts.len:
        if links[l] <= rechts[r]:
            result.add(links[l])
            inc(l)
        else:
            result.add(rechts[r])
            inc(r)

    while l < links.len:
        result.add(links[l])
        inc(l)

    while r < rechts.len:
        result.add(rechts[r])
        inc(r)

    return result

proc mergeSort*[T](lijst: var seq[T]): seq[T] =
    if lijst.len <= 1:
        return lijst
        
    var midden = lijst.len div 2
    var ongesorteerdLinks = lijst[0..<midden]
    var ongesorteerdRechts = lijst[midden..^1]

    var gesorteerdLinks = mergeSort(ongesorteerdLinks)
    var gesorteerdRechts = mergeSort(ongesorteerdRechts)

    return merge(gesorteerdLinks, gesorteerdRechts)

proc partitioneer[T](lijst: var seq[T], laag, hoog: int): int =
    let pivot = lijst[hoog]
    var i = laag

    for j in laag..<hoog:
        if lijst[j] <= pivot:
            swap(lijst[i], lijst[j])
            inc(i)

    swap(lijst[i], lijst[hoog])
    return i

proc quickSort*[T](lijst: var seq[T], laag, hoog: int) =
    if laag < hoog:

        let pivotIndex = partitioneer(lijst, laag, hoog)

        quickSort(lijst, laag, pivotIndex - 1)
        quickSort(lijst, pivotIndex + 1, hoog)

proc stalinSort*[T](lijst: var seq[T]): seq[T] =
    if lijst.len == 0: return @[]

    result = @[lijst[0]]
    var huidigeMax = lijst[0]

    for i in 1..<lijst.len:
        if lijst[i] >= huidigeMax:
            result.add(lijst[i])
            huidigeMax = lijst[i]

proc svenSort*[T](lijst: var seq[T], maxTime: float): seq[T] =
    let n = lijst.len
    let s = epochTime()

    for i in 0..<n:
        if n > 1000 and i mod 100 == 0: 
            let percent = (i * 100) div n
            stdout.write("\r") 
            stdout.resetAttributes()
            stdout.write(&"{percent}% bezig met SvenSort...\t")
            stdout.flushFile()

        for j in 0..<n - i - 1:
            if j mod 1000 == 0 and epochTime() - s > maxTime:
                echo "\nZeg maar dag aan uw data"
                return stalinSort(lijst)

            if lijst[j] > lijst[j+1]:
                swap(lijst[j], lijst[j+1])
    lijst
    