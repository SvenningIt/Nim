import std/os

let fileName = "todo.txt"
var fileContent = ""
var quit = false

if fileExists(fileName):
    fileContent = readFile(fileName)
    echo "bestand gevonden!\n"
else:
    echo "Niet gevonden, maar hier is er toch 1.\n"
    writeFile(fileName, fileContent)

while quit == false:
    echo "\nWat wil je doen?"
    echo "s of stop voor het programma te stoppen"
    echo "1 voor todo-lijst uitlezen"
    echo "2 voor bij de todo-lijst toe te voegen"
    echo "3 voor als de feds er zijn"

    var choice = readLine(stdin)
    if choice == "stop" or choice == "s":
        quit = true 
    echo ""
    

    case choice:
    of "1":
        echo readFile(fileName)
    of "2":
        echo "Typ je taken of stop "
        while true:
            stdout.write(": ")
            let input2 = readLine(stdin)
            if input2 == "stop" or input2 == "s":
                break

            let text = open(fileName, fmAppend)
            text.writeLine("-" & input2)
            text.close()
    of "3":
        writeFile(fileName, "")
        echo "Daar gaan ze!"
