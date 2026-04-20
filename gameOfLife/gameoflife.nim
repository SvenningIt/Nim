import raylib, sequtils, random

randomize()

const
    windowWidth = 1725
    screenWidth = (windowWidth - 225)
    screenHeight = 940
    cellSize = 10
    cols = screenWidth div cellSize
    rows = screenHeight div cellSize

type
    CellState = enum
        Dead, Alive

var 
    totalFrames = 0
    livingCells = 0
    oldestCell = 0
    birthCount = 0
    grid = newSeqWith(cols, newSeq[CellState](rows))
    nextGrid = newSeqWith(cols, newSeq[CellState](rows))
    ageGrid = newSeqWith(cols, newSeq[int](rows))
    isPaused = true
    lastUpdateTime: float64 = 0.0
    updateInterval: float64 = 0.1
    sliderX = screenWidth + 20
    sliderY = 300
    sliderWidth = 160
    knobX = screenWidth + 100
    isDraggingSlider = false
    birthRules = [false, false, false, true, false, false, false, false, false] #standaard conway is hardcoded
    survivalRules = [false, false, true, true, false, false, false, false, false]
    brushSize = 1
    brushControlY = int32(screenHeight-50)

let
    sidebarX = int32(screenWidth + 20)

proc countNeighbors(x, y: int): int =
    result = 0
    for i in -1..1:
        for j in -1..1:
            if i == 0 and j == 0: continue
            let nx = x + i
            let ny = y + j
            if nx >= 0 and nx < cols and ny >= 0 and ny < rows:
                if grid[nx][ny] == Alive:
                    inc result
  
proc updateSimulation() =
    inc totalFrames
    livingCells = 0
    oldestCell = 0
    birthCount = 0

    for x in 0..<cols:
        for y in 0..<rows:
            let neighbors = countNeighbors(x, y)
            let state = grid[x][y]

            if state == Alive:
                if survivalRules[neighbors]:
                    nextGrid[x][y] = Alive
                    ageGrid[x][y] += 1
                else:
                    nextGrid[x][y] = Dead
                    ageGrid[x][y] = 0
            else:
                if birthRules[neighbors]:
                    nextGrid[x][y] = Alive
                    ageGrid[x][y] = 1
                else:
                    nextGrid[x][y] = Dead

            if nextGrid[x][y] == Alive:
                inc livingCells
                if ageGrid[x][y] > oldestCell:
                    oldestCell = ageGrid[x][y]
                
                if grid[x][y] == Dead:
                    inc birthCount

    grid = nextGrid

initWindow(windowWidth, screenHeight, "Game of Life")
setTargetFPS(60)

while not windowShouldClose():
    let currentTime = getTime()

    let mPos = getMousePosition()

    if isMouseButtonPressed(MouseButton.Left):
        if mPos.x >= float32(knobX - 10) and mPos.x <= float32(knobX + 10) and
        mPos.y >= float32(sliderY - 10) and mPos.y <= float32(sliderY + 10):
            isDraggingSlider = true

    if isMouseButtonReleased(MouseButton.Left):
        isDraggingSlider = false

    if isDraggingSlider:
        knobX = int(mPos.x)
        if knobX < sliderX: knobX = sliderX
        if knobX > sliderX + sliderWidth: knobX = sliderX + sliderWidth
    
        let percent = (knobX - sliderX) / sliderWidth
        updateInterval = 0.5 - (percent * 0.49)

    if isKeyPressed(I):
            for x in 0..<cols:
                for y in 0..<rows:
                    grid[x][y] = if grid[x][y] == Alive: Dead else: Alive

    if isKeyPressed(Space):
        isPaused = not isPaused

    if not isPaused:
        if currentTime - lastUpdateTime >= updateInterval:
            updateSimulation()
            lastUpdateTime = currentTime

    else:
        if isMouseButtonPressed(MouseButton.Left):
            let 
                mPos = getMousePosition()

            for i in 0..8:
                let 
                    bx = int32(sidebarX + (i * 22))
                    byBirth = int32(365)
                    bySurvival = int32(byBirth+80)
            
                if mPos.x >= float32(bx) and mPos.x <= float32(bx + 20) and mPos.y >= float32(byBirth) and mPos.y <= float32(byBirth + 20):
                    birthRules[i] = not birthRules[i]

                if mPos.x >= float32(bx) and mPos.x <= float32(bx + 20) and mPos.y >= float32(bySurvival) and mPos.y <= float32(bySurvival + 20):
                    survivalRules[i] = not survivalRules[i] 

            if mPos.x >= float32(sidebarX) and mPos.x <= float32(sidebarX + 30) and mPos.y >= float32(brushControlY) and mPos.y <= float32(brushControlY + 30):
                brushSize = max(1, brushSize - 1)
        
            if mPos.x >= float32(sidebarX + 70) and mPos.x <= float32(sidebarX + 100) and mPos.y >= float32(brushControlY) and mPos.y <= float32(brushControlY + 30):
                brushSize = min(10, brushSize + 1)

        if isMouseButtonDown(MouseButton.Left):
            let 
                mPos = getMousePosition()
                offset = brushSize - 1

            if mPos.x < float32(screenWidth):
                let mx = int(mPos.x) div cellSize
                let my = int(mPos.y) div cellSize

                for dx in -offset..offset:
                    for dy in -offset..offset:
                        let nx = mx + dx
                        let ny = my + dy
                        if nx >= 0 and nx < cols and ny >= 0 and ny < rows:
                            grid[nx][ny] = Alive
                            ageGrid[nx][ny] = 1

        if isMouseButtonDown(MouseButton.Right):
            let 
                mPos = getMousePosition()
                mx = int(mPos.x) div cellSize
                my = int(mPos.y) div cellSize
                offset = brushSize - 1

            for dx in -offset..offset:
                for dy in -offset..offset:
                    let nx = mx + dx
                    let ny = my + dy
                    if nx >= 0 and nx < cols and ny >= 0 and ny < rows:
                        grid[nx][ny] = Dead
                        ageGrid[nx][ny] = 0

        if isKeyPressed(R):
            totalFrames = 0
            livingCells = 0
            oldestCell = 0
            birthCount = 0
            for x in 0..<cols:
                for y in 0..<rows:
                    grid[x][y] = if rand(1.0) > 0.8: Alive else: Dead
        
        if isKeyPressed(C):
            totalFrames = 0
            livingCells = 0
            oldestCell = 0
            birthCount = 0
            for x in 0..<cols:
                for y in 0..<rows:
                    grid[x][y] = Dead

        if isKeyPressed(S):     
            for y in 0..<rows:
                var line = ""
                for x in 0..<cols:
                    line &= (if grid[x][y] == Alive: "X" else: ".")
                echo line

    beginDrawing()
    clearBackground(Black)

    for x in 0..<cols:
        for y in 0..<rows:
            if grid[x][y] == Alive:
                let age = ageGrid[x][y]
            
                let greenValue = uint8(max(50, 255 - (age * 5)))
                let customGreen = Color(r: 0, g: greenValue, b: 0, a: 255)

                drawRectangle(int32(x * cellSize), int32(y * cellSize), cellSize - 1, cellSize - 1, customGreen)

    drawRectangle(screenWidth, 0, (windowWidth-800), screenHeight, Color(r: 30, g: 30, b: 30, a: 255))
    drawRectangleLines(screenWidth, 0, 1, screenHeight, Gray)

    drawText("DASHBOARD", sidebarX, 20, 20, Yellow)
    drawText("Frames: " & $totalFrames, sidebarX, 60, 20, White)
    drawText("Alive: " & $livingCells, sidebarX, 90, 20, White)
    drawText("Oldest: " & $oldestCell, sidebarX, 120, 20, White)
    drawText("Births: " & $birthCount, sidebarX, 150, 20, White)

    if isPaused:
        drawText("STATUS: PAUSED", sidebarX, 200, 20, Red)
    else:
        drawText("STATUS: RUNNING", sidebarX, 200, 20, Green)

    drawRectangle(int32(sliderX), int32(sliderY), int32(sliderWidth), 4, DarkGray)
    let knobColor = if isDraggingSlider: Yellow else: Raywhite
    drawCircle(int32(knobX), int32(sliderY + 2), 8, knobColor)
    drawText("SPEED", int32(sliderX), int32(sliderY - 35), 20, White)

    for i in 0..8:
        let 
            bx = int32(sidebarX + (i * 22))
            byBirth = int32(365)
            bySurvival = int32(byBirth+80)

        let bColor = if birthRules[i]: Green else: DarkGray
        drawRectangle(bx, byBirth, 20, 20, bColor)
        drawText($i, bx + 6, byBirth + 4, 15, White)

        let sColor = if survivalRules[i]: Blue else: DarkGray
        drawRectangle(bx, bySurvival, 20, 20, sColor)
        drawText($i, bx + 6, bySurvival + 4, 15, White)

    drawText("BIRTH (B)", sidebarX, 340, 20, White)
    drawText("SURVIVAL (S)", sidebarX, 420, 20, White)

    drawText("BRUSH SIZE", sidebarX, brushControlY - 30, 20, White)
    drawRectangle(sidebarX, brushControlY, 30, 30, DarkGray)
    drawText("-", sidebarX + 10, brushControlY + 5, 20, White)

    drawText($brushSize, sidebarX + 45, brushControlY + 5, 20, Yellow)

    drawRectangle(sidebarX + 70, brushControlY, 30, 30, DarkGray)
    drawText("+", sidebarX + 80, brushControlY + 5, 20, White)

    endDrawing()

closeWindow()