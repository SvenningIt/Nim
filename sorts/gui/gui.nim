import guiSorts, nigui, random, strutils, times
#import os #-> ontcommentaren als je sleep wilt gebruiken

app.init()
randomize()

var getallen: seq[int] = @[]

var window = newWindow("Sorts GUI")
window.width = 1200.int
window.height = 600.int

var statsWindow = newWindow("Stats")
statsWindow.width = 250.int
statsWindow.height = 120.int

var buffer = newImage()
if window.width > 0 and window.height > 100:
  buffer.resize(window.width.int, window.height.int - 80)

proc updateVisualisatie(actieveIndex: int = -1, isChecking: bool = false) =
    
    let c = buffer.canvas
    let w = buffer.width
    let h = buffer.height
    
    # achtergrond 
    c.areaColor = rgb(30, 30, 30) 
    c.drawRectArea(0, 0, w, h)
    
    # balkjes
    let bBreedte = w.float / getallen.len.float 

    for k, waarde in getallen:
        let xPos = k.float * bBreedte
        if isChecking:
            if k <= actieveIndex:
                c.areaColor = rgb(50, 205, 50)
            else:
                let kleur = byte((waarde * 255) div 520)
                c.areaColor = rgb(kleur, 150, 255)
        else:
            if k == actieveIndex or k == actieveIndex + 1:
                c.areaColor = rgb(255, 255, 0) 
            else:
                let kleur = byte((waarde * 255) div 520)
                c.areaColor = rgb(kleur, 150, 255)
        c.drawRectArea(xPos.int, h - waarde, (bBreedte - 1.0).int, waarde)

template runVisualisatie(chosenSort: untyped) =
    let startTime = epochTime()
    comparisons = 0
    swaps = 0

    for pos in chosenSort:
        updateVisualisatie(pos, isChecking = false) 
        canvasSorts.forceRedraw()
        app.processEvents()
        let currentTime = epochTime() - startTime
        labelTime.text = "Tijd: " & currentTime.formatFloat(ffDecimal, 2) & "s"
        labelComparisons.text = "Vergelijkingen: " & $comparisons
        labelSwaps.text = "Swaps: " & $swaps
    
    for i in 0..<getallen.len:
        updateVisualisatie(i, isChecking = true) 
        canvasSorts.forceRedraw()

        app.processEvents()
        #sleep(1) #-> import os ontcommentaren indien je dit wilt gebruiken
        
    updateVisualisatie(-1)
    canvasSorts.forceRedraw()  
# gui shi
var container = newLayoutContainer(Layout_Vertical)
window.add(container)
container.padding = 0
container.spacing = 0

var canvasSorts = newControl()
canvasSorts.widthMode = WidthMode_Expand
canvasSorts.heightMode = HeightMode_Expand
container.add(canvasSorts)

var buttons = newLayoutContainer(Layout_Horizontal)
container.add(buttons)
container.padding = 0
container.spacing = 0

var numberOfElements = newTextBox("20")
numberOfElements.width = 50.int
buttons.add(numberOfElements)

var btnShuffle = newButton("Shuffle")
buttons.add(btnShuffle)

var algorithmSelector = newComboBox(@["Bubble Sort", "Selection Sort", "Insertion Sort", "Shell Sort", "Merge Sort", "Quick Sort", "Stalin Sort", "Sven Sort", "Radix Sort", "Heap Sort", "Power Sort"])
buttons.add(algorithmSelector)

var btnStart = newButton("Start")
buttons.add(btnStart)

var labelContainer = newLayoutContainer(Layout_Vertical)
statsWindow.add(labelContainer)

var labelComparisons = newLabel("Vergelijkingen: 0")
labelContainer.add(labelComparisons)

var labelSwaps = newLabel("Swap: 0")
labelContainer.add(labelSwaps)

var labelTime = newLabel("Tijd: 0s")
labelContainer.add(labelTime)

canvasSorts.onDraw = proc (event: DrawEvent) =
  event.control.canvas.drawImage(buffer, 0, 0, event.control.width.int, event.control.height.int)

window.onResize = proc (event: auto) =
  let w = canvasSorts.width.int - 300
  let h = canvasSorts.height.int
  
  if w > 0 and h > 0: 
    buffer.resize(w, h)
    updateVisualisatie()
    canvasSorts.forceRedraw()

btnShuffle.onClick = proc(event: ClickEvent) =
    try:
        let aantal = numberOfElements.text.parseInt()
        reset(getallen)

        for i in 0 ..< aantal:
            getallen.add(rand(0 .. 520))

        updateVisualisatie(-1)
        canvasSorts.forceRedraw()
    except ValueError:
        window.alert("Nuh Uh")

btnStart.onClick = proc(event: ClickEvent) =

    let chosenAlgorithm = algorithmSelector.options[algorithmSelector.index]

    case chosenAlgorithm:
        of "Bubble Sort":
            runVisualisatie(bubbleSort(getallen))
        of "Selection Sort":
            runVisualisatie(selectionSort(getallen))
        of "Insertion Sort":
            runVisualisatie(insertionSort(getallen))
        of "Shell Sort":
            runVisualisatie(shellSort(getallen))
        of "Merge Sort":
            runVisualisatie(mergeSort(getallen))
        of "Quick Sort":
            runVisualisatie(quickSort(getallen))
        of "Stalin Sort":
            runVisualisatie(stalinSort(getallen))
        of "Sven Sort":
            runVisualisatie(svenSort(getallen, 2))
        of "Radix Sort":
            runVisualisatie(radixSort(getallen))
        of "Heap Sort":
            runVisualisatie(heapSort(getallen))
        of "Power Sort":
            runVisualisatie(powerSort(getallen))
        else:
            window.alert("Hoe heb je dit nu weer gedaan?") 

window.show()
statsWindow.show()

if window.width > 0 and window.height > 100:
    buffer.resize(window.width.int, window.height.int - 80)
    updateVisualisatie() 
    canvasSorts.forceRedraw()

app.run()