import raylib, sequtils, random

randomize()

const
    screenWidth = 1600
    screenHeight = 800
    cellSize = 7
    cols = screenWidth div cellSize
    rows = screenHeight div cellSize

type
    Elementype = enum 
        Empty, Sand, Oil, Water, Stone, Gravel, Acid, Fire, Wood, Gunpowder, Lava

var grid = newSeqWith(cols, newSeq[Elementype](rows))
var currentElement: Elementype = Sand

proc density(element:Elementype): int =
    case element
    of Empty: 0
    of Fire: 1
    of Acid: 2
    of Oil: 3
    of Water: 5
    of Gunpowder: 7
    of Lava: 8
    of Sand: 10
    of Gravel: 10
    of Wood: 90
    of Stone: 100
    

proc tryMove(x, y, nx, ny: int): bool =
    if nx < 0 or nx >= cols or ny < 0 or ny >= rows: #valid fni
        return false

    let current = grid[x][y]
    let neighbor = grid[nx][ny]

    if density(current) > density(neighbor): 
        grid[nx][ny] = current
        grid[x][y] = neighbor
        return true
    return false

proc explode(cx, cy, radius: int) =
    for y in (cy - radius) .. (cy + radius):
        for x in (cx - radius) .. (cx + radius):
            let dx = x - cx
            let dy = y - cy
            if (dx*dx + dy*dy) <= (radius * radius):
                if x >= 0 and x < cols and y >= 0 and y < rows:
                    if grid[x][y] != Stone: 
                        grid[x][y] = Fire

proc updateSand(x, y: int) =
    if tryMove(x, y, x, y + 1): return #beneden
    if tryMove(x, y, x - 1, y + 1): return #links
    if tryMove(x, y, x + 1, y + 1): return #rechts

proc updateWater(x, y: int) =
    if tryMove(x, y, x, y + 1): return
    if tryMove(x, y, x - 1, y + 1): return
    if tryMove(x, y, x + 1, y + 1): return

    let sideDirection = if rand(1.0) > 0.5: 1 else: -1
    if tryMove(x, y, x + sideDirection, y): return #random rechts
    if tryMove(x, y, x - sideDirection, y): return #random links

proc updateOil(x, y: int) =
    if tryMove(x, y, x, y + 1): return
    if tryMove(x, y, x - 1, y + 1): return
    if tryMove(x, y, x + 1, y + 1): return

    let sideDirection = if rand(1.0) > 0.5: 1 else: -1
    if tryMove(x, y, x + sideDirection, y): return #random rechts
    if tryMove(x, y, x - sideDirection, y): return #random links

proc updateGravel(x, y: int) =
    if tryMove(x, y, x, y + 1): return
    
    if rand(1.0) > 0.4: # 60% kans
        if tryMove(x, y, x + 1, y + 2): return
        if tryMove(x, y, x - 1, y + 2): return

proc updateAcid(x, y: int) =
    let nx = x
    let ny = y + 1

    if nx >= 0 and nx < cols and ny >= 0 and ny < rows:
        let target = grid[nx][ny]
        
        if target == Oil:
            explode(x, y, 5)
            grid[nx][ny] = Empty
            grid[x][y] = Empty 
        elif target != Empty and target != Acid and target != Stone: 
            grid[nx][ny] = Empty
            grid[x][y] = Empty 
            return 
    updateWater(x, y)

proc updateFire(x, y: int) =
    let neighbors = [(x, y-1), (x, y+1), (x-1, y), (x+1, y)]
  
    for n in neighbors:
        let (nx, ny) = n
        if nx >= 0 and nx < cols and ny >= 0 and ny < rows:
            if grid[nx][ny] == Wood:
                if rand(1.0) < 0.1: 
                    grid[nx][ny] = Fire

    if rand(1.0) < 0.02:
        grid[x][y] = Empty
        return
    elif rand(1.0) < 0.5: 
        discard tryMove(x, y, x + rand(-1..1), y - 1)

proc updateGunpowder(x, y: int) =
    if tryMove(x, y, x, y + 1): return
    if tryMove(x, y, x - 1, y + 1): return 
    if tryMove(x, y, x + 1, y + 1): return
  
    let neighbors = [(x, y-1), (x, y+1), (x-1, y), (x+1, y)]
    for n in neighbors:
        let (nx, ny) = n
        if nx >= 0 and nx < cols and ny >= 0 and ny < rows:
            if grid[nx][ny] == Fire:
                explode(x, y, 10)
                return

proc updateLava(x, y: int) =
    if rand(1.0) > 0.4: 
        return

    let neighbors = [(x, y-1), (x, y+1), (x-1, y), (x+1, y)]
    for n in neighbors:
        let (nx, ny) = n
        if nx >= 0 and nx < cols and ny >= 0 and ny < rows:
            if grid[nx][ny] == Water:
                grid[x][y] = Stone     
                grid[nx][ny] = Stone 
                return
            
            elif grid[nx][ny] == Gunpowder or grid[nx][ny] == Acid or grid[nx][ny] == Oil:
                if rand(1.0) > 0.1:
                    explode(x, y, 10)
                    return
                grid[x][y] = Empty     
                grid[nx][ny] = Empty 

            elif grid[nx][ny] == Wood:
                if rand(1.0) > 0.6:
                    grid[x][y] = Empty     
                    grid[nx][ny] = Fire 

    updateWater(x, y)

proc updateSimulation() =
    for y in countdown(rows - 1, 0):
        for x in 0..<cols:
            let element = grid[x][y]
            if element in {Sand, Water, Oil, Gravel, Acid, Gunpowder, Lava}:
                case element
                of Sand: updateSand(x, y)
                of Water: updateWater(x, y)
                of Oil: updateOil(x, y)
                of Gravel: updateGravel(x, y)
                of Acid: updateAcid(x, y)
                of Gunpowder: updateGunpowder(x, y)
                of Lava: updateLava(x, y)
                else: discard

    for y in 0..<rows:
        for x in 0..<cols:
            if grid[x][y] == Fire:
                updateFire(x, y)

initWindow(screenWidth, screenHeight, "Sand game")
setTargetFPS(60)

while not windowShouldClose():
    if isKeyPressed(One):   currentElement = Sand
    if isKeyPressed(Two):   currentElement = Water
    if isKeyPressed(Three):   currentElement = Stone
    if isKeyPressed(Four):   currentElement = Oil
    if isKeyPressed(Five):   currentElement = Gravel
    if isKeyPressed(Six):   currentElement = Acid
    if isKeyPressed(Seven): currentElement = Wood
    if isKeyPressed(Eight): currentElement = Gunpowder
    if isKeyPressed(Nine): currentElement = Lava

    if isMouseButtonDown(MouseButton.Left):
        let mPos = getMousePosition()
        let x = int(mPos.x) div cellSize
        let y = int(mPos.y) div cellSize
        if x >= 0 and x < cols and y >= 0 and y < rows:
            grid[x][y] = currentElement

    if isMouseButtonDown(MouseButton.Right):
        let mPos = getMousePosition()
        let x = int(mPos.x) div cellSize
        let y = int(mPos.y) div cellSize
        if x >= 0 and x < cols and y >= 0 and y < rows:
            explode(x, y, 5)
    
    updateSimulation()

    beginDrawing()
    clearBackground(Black)

    for x in 0..<cols:
        for y in 0..<rows:
            case grid[x][y]
            of Sand:
                drawRectangle(int32(x * cellSize), int32(y * cellSize), cellSize, cellSize, Gold)
            of Water:
                drawRectangle(int32(x * cellSize), int32(y * cellSize), cellSize, cellSize, Blue)
            of Oil:
                drawRectangle(int32(x * cellSize), int32(y * cellSize), cellSize, cellSize, Yellow)
            of Stone:
                drawRectangle(int32(x * cellSize), int32(y * cellSize), cellSize, cellSize, Gray)   
            of Gravel:
                drawRectangle(int32(x * cellSize), int32(y * cellSize), cellSize, cellSize, LightGray)
            of Acid:
                drawRectangle(int32(x * cellSize), int32(y * cellSize), cellSize, cellSize, Green) 
            of Fire:
                let colors = [Orange, Red, Gold, Yellow]
                drawRectangle(int32(x * cellSize), int32(y * cellSize), cellSize, cellSize, colors[rand(2)])
            of Wood:
                drawRectangle(int32(x * cellSize), int32(y * cellSize), cellSize, cellSize, Brown) 
            of Gunpowder:
                drawRectangle(int32(x * cellSize), int32(y * cellSize), cellSize, cellSize, Darkgray)  
            of Lava:
                let lavaColors = [Red, Orange, Maroon]
                drawRectangle(int32(x * cellSize), int32(y * cellSize), cellSize, cellSize, lavaColors[rand(2)])
            of Empty:
                discard
    
    drawText("1: Sand | 2: Water | 3: Stone | 4: Oil | 5: Gravel | 6: Acid | 7: Wood | 8: Gunpowder | 9: Lava", 10, 10, 20, White)
    drawText("Current: " & $currentElement, 10, 35, 20, LightGray)

    endDrawing()
closeWindow()