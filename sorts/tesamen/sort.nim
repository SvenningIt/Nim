import strutils, sequtils, times, math, random, strformat, algorithm, terminal

proc printLijst[T](prefix: string, x: int, lijst: seq[T]) =
    echo prefix, x, ": ", lijst.mapIt($it).join(". ")

proc bubbleSort[T](lijst: var seq[T]): seq[T] =
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
    return lijst

proc selectionSort[T](lijst: var seq[T]): seq[T] =
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
    return lijst

proc insertionSort[T](lijst: var seq[T]): seq[T] =
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
    return lijst

proc shellSort[T](lijst: var seq[T]): seq[T] =
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
    return lijst

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

proc mergeSort[T](lijst: var seq[T]): seq[T] =
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

proc quickSort[T](lijst: var seq[T], laag, hoog: int) =
    if laag < hoog:

        let pivotIndex = partitioneer(lijst, laag, hoog)

        quickSort(lijst, laag, pivotIndex - 1)
        quickSort(lijst, pivotIndex + 1, hoog)

proc genereerLijst(aantal: int, min: float, max: float): seq[float] =
    randomize()
    result = newSeq[float](aantal)
    for i in 0..<aantal:
        let getal = round(rand(max - min) + min, 3)
        result[i] = getal

proc toonLijst[T](lijst: seq[T]) =
    if lijst.len < 1000:
        echo "Finis: ", lijst.mapIt($it).join(", ")
    
    else:
        echo "Lengte: ", lijst.len
        echo "10 laagste: ", lijst[0..9].mapIt($it).join(", ")
        echo "10 hoogste: ", lijst[^10..^1].mapIt($it).join(", ")

proc main() =
    hideCursor()
    defer: showCursor()

    echo "\n(1) Handmatig woorden\n(2) Handmatig getallen\n(3) Automatisch getallen"
    let methode = readLine(stdin)

    var getallen: seq[float]
    var woorden: seq[string]
    var isWoorden = false

    case methode
    of "1":
        isWoorden = true
        echo "\nVoer een lijst van woorden in (gescheiden door komma's):"
        var input = readLine(stdin)
        var lijst = input.split(",")
        woorden = lijst.mapIt(it.strip())
    of "2":
        echo "\nEen lijst van cijfers (gescheiden door komma's)\nMogen floats zijn!!"
        var input = readLine(stdin)
        var lijst = input.split(",")
        getallen = lijst.mapIt(it.strip().parseFloat())
    of "3":
        echo "\nHoelang moet de lijst zijn?"
        let n = readLine(stdin).parseInt()
        getallen = genereerLijst(n, -1000.0, 1000.0)
        if getallen.len < 100:
            echo "Lijst: ", getallen.mapIt($it).join(", ")
    else: echo "Ongeldige keuze"

    echo "\nWelk algoritme?\n \t(0: Benchmark)\n\t(1: Bubble)\n\t(2: Selection)\n\t(3: Insertion)\n\t(4: Shell)\n\t(5: Merge)\n\t(6: Quick)"
    var keuze = readLine(stdin)
    var resultaat: seq[float]

    if isWoorden: #woorden sorteren
        let start = cpuTime()
        case keuze:
            of "1": discard woorden.bubbleSort
            of "2": discard woorden.selectionSort
            of "3": discard woorden.insertionSort
            of "4": discard woorden.shellSort
            of "5": woorden = woorden.mergeSort
            of "6": quickSort(woorden, 0, woorden.len - 1)
            else: echo "Ongeldig"
        let einde = cpuTime()
        echo "\nTijd: ", round(einde - start, 10), " seconden\n"
        woorden.toonLijst
    else: #nummers
        case keuze:
        of "0":
            let ongesorteerdeLijst = getallen
            var resultaten: seq[tuple[naam: string, tijd: float]] = @[]
            let types = ["Bubble", "Selection", "Insertion", "Shell", "Merge", "Quick"]
            for t in types:
                var kopie = ongesorteerdeLijst
                
                let s = cpuTime()
                case t:
                    of "Bubble":    discard kopie.bubbleSort
                    of "Selection": discard kopie.selectionSort
                    of "Insertion": discard kopie.insertionSort
                    of "Shell":     discard kopie.shellSort
                    of "Merge":     kopie = kopie.mergeSort
                    of "Quick":     quickSort(kopie, 0, kopie.len - 1)
                let e = cpuTime()
                echo ""
                let tijd = e - s
                resultaten.add((naam: t, tijd: tijd))

                echo t, " Sort: ", round(tijd, 10), " sec"

            resultaten.sort(proc(x, y: tuple[naam: string, tijd: float]): int =
                cmp(x.tijd, y.tijd)
            )

            echo "\n\n\n"
            for res in resultaten:
                if res.tijd < 0.1:
                    stdout.setForegroundColor(fgGreen)
                elif res.tijd < 1:
                    stdout.setForegroundColor(fgCyan)
                elif res.tijd < 10:
                    stdout.setForegroundColor(fgYellow)
                else:
                    stdout.setForegroundColor(fgRed)

                echo res.naam, ": ", round(res.tijd, 10), "s"
                stdout.resetAttributes()
        of "1": 
            let start = cpuTime()
            resultaat = getallen.bubbleSort
            let einde = cpuTime()
            echo "\nTijd: ", round(einde - start, 10), " seconden\n"
            getallen.toonLijst
        of "2":
            let start = cpuTime()
            resultaat = getallen.selectionSort
            let einde = cpuTime()
            echo "\nTijd: ", round(einde - start, 10), " seconden\n"
            getallen.toonLijst
        of "3":
            let start = cpuTime()
            resultaat = getallen.insertionSort
            let einde = cpuTime()
            echo "\nTijd: ", round(einde - start, 10), " seconden\n"
            getallen.toonLijst
        of "4":
            let start = cpuTime()
            resultaat = getallen.shellSort
            let einde = cpuTime()
            echo "\nTijd: ", round(einde - start, 10), " seconden\n"
            getallen.toonLijst
        of "5":
            let start = cpuTime()
            getallen = getallen.mergeSort
            let einde = cpuTime()
            echo "\nTijd: ", round(einde - start, 10), " seconden\n"
            getallen.toonLijst
        of "6":
            let start = cpuTime()
            quickSort(getallen, 0, getallen.len - 1)
            let einde = cpuTime()
            echo "\nTijd: ", round(einde - start, 10), " seconden\n"
            getallen.toonLijst
        else: echo "Ongeldig"

    echo "\nDruk op enter om af te sluiten..."
    discard readLine(stdin)

when isMainModule:
    main()