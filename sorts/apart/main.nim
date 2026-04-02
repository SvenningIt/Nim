import strutils, sequtils, times, math, random, terminal, algorithm
import sorts #zelf gemaakt

proc genereerLijst(aantal: int, min: float, max: float): seq[float] =
    result = newSeq[float](aantal)
    for i in 0..<aantal:
        let getal = round(rand(max - min) + min, 3)
        result[i] = getal

proc toonLijst[T](lijst: seq[T]) =
    if lijst.len < 10:
        echo "Finis: ", lijst.mapIt($it).join(", "), "\n"
    else:
        echo "Lengte: ", lijst.len
        echo "5 laagste: ", lijst[0..4].mapIt($it).join(", ")
        echo "5 hoogste: ", lijst[^5..^1].mapIt($it).join(", "), "\n"

proc main() =
    randomize()
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

    echo "\nWelk algoritme?\n \t(Std: Ingebouwd)\n\t(0: Benchmark)\n\t(1: Bubble)\n\t(2: Selection)\n\t(3: Insertion)\n\t(4: Shell)\n\t(5: Merge)\n\t(6: Quick)\n\t(7: Stalin)\n\t(8: Sven)"
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
        of "Std":
            let s = cpuTime()
            getallen.sort
            let e = cpuTime()
            echo e - s
        of "0":
            let ongesorteerdeLijst = getallen
            var resultaten: seq[tuple[naam: string, tijd: float]] = @[]
            let types = ["Std", "Bubble", "Selection", "Insertion", "Shell", "Merge", "Quick", "Stalin", "Sven"]
            for t in types:
                var kopie = @ongesorteerdeLijst
                
                let s = cpuTime()
                case t:
                    of "Std": kopie.sort
                    of "Bubble":    discard kopie.bubbleSort
                    of "Selection": discard kopie.selectionSort
                    of "Insertion": discard kopie.insertionSort
                    of "Shell":     discard kopie.shellSort
                    of "Merge":     kopie = kopie.mergeSort
                    of "Quick":     
                        if kopie.len > 0:
                            quickSort(kopie, 0, kopie.len - 1)
                    of "Stalin": discard kopie.stalinSort
                    of "Sven": discard svenSort(kopie, 2.5)
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
                if res.tijd < 0.02:
                    stdout.setForegroundColor(fgMagenta)
                elif res.tijd < 0.1:
                    stdout.setForegroundColor(fgGreen)
                elif res.tijd < 3:
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
            resultaat.toonLijst
        of "2":
            let start = cpuTime()
            resultaat = getallen.selectionSort
            let einde = cpuTime()
            echo "\nTijd: ", round(einde - start, 10), " seconden\n"
            resultaat.toonLijst
        of "3":
            let start = cpuTime()
            resultaat = getallen.insertionSort
            let einde = cpuTime()
            echo "\nTijd: ", round(einde - start, 10), " seconden\n"
            resultaat.toonLijst
        of "4":
            let start = cpuTime()
            resultaat = getallen.shellSort
            let einde = cpuTime()
            echo "\nTijd: ", round(einde - start, 10), " seconden\n"
            resultaat.toonLijst
        of "5":
            let start = cpuTime()
            resultaat = getallen.mergeSort
            let einde = cpuTime()
            echo "\nTijd: ", round(einde - start, 10), " seconden\n"
            resultaat.toonLijst
        of "6":
            let start = cpuTime()
            quickSort(getallen, 0, getallen.len - 1)
            resultaat = getallen
            let einde = cpuTime()
            echo "\nTijd: ", round(einde - start, 10), " seconden\n"
            resultaat.toonLijst
        of "7":
            let start = cpuTime()
            resultaat = getallen.stalinSort
            let einde = cpuTime()

            resultaat.toonLijst
            echo "\nTijd: ", round(einde - start, 10), " seconden\n"
            echo "# elementen in de lijst: ", resultaat.len
            echo "# elementen naar de gulag: ", getallen.len - resultaat.len
        of "8":
            let start = cpuTime()
            resultaat = svenSort(getallen, 2.5)
            let einde = cpuTime()
            resultaat.toonLijst
            echo "# elementen in de lijst: ", resultaat.len
            echo "# elementen naar de gulag: ", getallen.len - resultaat.len
            let percentage = (resultaat.len.float / getallen.len.float) * 100
            echo "Overlevingskans: ", round(percentage, 2), "%"

        else: echo "Ongeldig"

    echo "\nDruk op enter om af te sluiten..."
    discard readLine(stdin)

when isMainModule:
    main()